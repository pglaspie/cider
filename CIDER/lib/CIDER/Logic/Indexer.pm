package CIDER::Logic::Indexer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp;

use Lucy;

use String::CamelCase qw(decamelize);

# Constants
use Readonly;
# $EMPTY_FIELD_VALUE is the indexed value for object fields with empty values.
Readonly my $EMPTY_FIELD_VALUE => 'CIDERNULL';

has schema => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
);

has path_to_index => (
    is => 'ro',
    isa => 'Str',
);

has _indexer => (
    is => 'rw',
    isa => 'Maybe[Lucy::Index::Indexer]',
);

has _in_txn => (
    is => 'rw',
    isa => 'Bool',
);

# Create the index schema.
# We'll try to have all the indexes share the same one...
my $index_schema = Lucy::Plan::Schema->new;
my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
    language => 'en',
);

# Define some basic types. Just being coarse for now.
my $text_type = Lucy::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 1,
);

my $unstored_text = Lucy::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 0,
    stored   => 0,
);

my $string_type = Lucy::Plan::StringType->new( sortable => 1 );
my $storage_only = Lucy::Plan::StringType->new( indexed => 0 );
my $index_only = Lucy::Plan::StringType->new( stored => 0 );
my $int_type    = Lucy::Plan::Int32Type->new;

# Define the fields.
my @object_text_fields
    = qw(
            number
            title
    );

my @collection_text_fields
    = qw(
            history
            scope
            organization
            notes
            processing_status
            processing_notes
            permanent_url
            pid
            publication_status
    );

my @series_text_fields
    = qw(
            description
            arrangement
            notes
    );

my @item_text_fields
    = qw(
            restrictions
            accession_number
            dc_type
            description
            volume
            issue
            abstract
            citation
    );

# Multitext fields are one-to-many text fields.  Their values are just
# joined with newlines and treated as single text fields.
my @collection_multitext_fields
    = qw(
            material
            languages
            subjects
    );

my @item_multitext_fields
    = qw(
            creators
            personal_names
            corporate_names
            topic_terms
            geographic_terms
    );

my @item_class_fields
    = qw(
            location_title
            browsing_object_pid
            browsing_object_thumbnail_pid
            barcode
            rights
            format
        );

for my $field ( @object_text_fields,
                @collection_text_fields,
                @series_text_fields,
                @item_text_fields,
                @collection_multitext_fields,
                @item_multitext_fields,
                @item_class_fields,
              ) {
    $index_schema->spec_field( name => $field, type => $text_type );
}

$index_schema->spec_field( name => 'id', type => $string_type );


=head1 METHODS

=head2 make_index

Create a new index for all objects in the database, replacing the
existing index if any.  The new index will be optimized.

=cut

sub make_index {
    my $self = shift;

    # This method will invalidate the index, so there's no use allowing
    # the current transaction to complete.
    $self->txn_rollback;

    my $indexer = Lucy::Index::Indexer->new(
        index => $self->path_to_index,
        schema => $index_schema,
        create => 1,
        truncate => 1,
    );

    my $object_rs = $self->schema->resultset( 'Object' );

    _add_rs_to_indexer( $object_rs, $indexer );

    $indexer->optimize;
    $indexer->commit;

    return $object_rs->count;
}

=head2 add_rs( $object_rs )

Add all objects in a result set to the index.

=cut

sub add_rs {
    my $self = shift;
    my ( $object_rs ) = @_;

    my $indexer = $self->_indexer;

    _add_rs_to_indexer( $object_rs, $indexer );

    $self->_commit;
}

=head2 add( $object )

Add an object to the index.

=cut

sub add {
    my $self = shift;
    my ( $object ) = @_;

    my $indexer = $self->_indexer;

    _add_to_indexer( $object, $indexer );

    $self->_commit;
}

=head2 update_rs( $object_rs )

Update all objects in a result set in the index.

=cut

sub update_rs {
    my $self = shift;
    my ( $object_rs ) = @_;

    my $indexer = $self->_indexer;

    _remove_rs_from_indexer( $object_rs, $indexer );
    _add_rs_to_indexer( $object_rs, $indexer );

    $self->_commit;
}

=head2 update( $object )

Update an object in the index.

=cut

sub update {
    my $self = shift;
    my ( $object ) = @_;

    my $indexer = $self->_indexer;

    _remove_from_indexer( $object, $indexer );
    _add_to_indexer( $object, $indexer );

    $self->_commit;
}

=head2 remove_rs( $object_rs )

Remove all objects in a result set from the index.

=cut

sub remove_rs {
    my $self = shift;
    my ( $object_rs ) = @_;

    my $indexer = $self->_indexer;

    _remove_rs_from_indexer( $object_rs, $indexer );

    $self->_commit;
}

=head2 remove( $object )

Remove an object from the index.

=cut

sub remove {
    my $self = shift;
    my ( $object ) = @_;

    my $indexer = $self->_indexer;

    _remove_from_indexer( $object, $indexer );

    $self->_commit;
}

=head2 txn_begin

Begin a transaction.  Changes to the index will not take effect unless
and until txn_commit is called.

=cut

sub txn_begin {
    my $self = shift;

    $self->_in_txn( 1 );
}

=head2 txn_rollback

Cancel the current transaction, discarding any changes to the index.

=cut

sub txn_rollback {
    my $self = shift;

    $self->_in_txn( 0 );
    $self->_indexer( undef );
}

=head2 txn_commit

End the current transaction, making all changes to the index at once.

=cut

sub txn_commit {
    my $self = shift;

    $self->_in_txn( 0 );
    $self->_commit;
}

### Private methods

sub _commit {
    my $self = shift;

    unless ( $self->_in_txn ) {
        $self->_indexer->commit;
        $self->_indexer( undef );
    }
}

around _indexer => sub {
    my ( $orig, $self ) = ( shift, shift );

    return $self->$orig( @_ ) if @_;

    my $indexer = $self->$orig;
    unless ( $indexer ) {
        $indexer = Lucy::Index::Indexer->new(
            index => $self->path_to_index,
            schema => $index_schema,
            create => 1,
        );
        $self->$orig( $indexer );
    }

    return $indexer;
};

sub _add_rs_to_indexer {
    my ( $object_rs, $indexer ) = @_;

    $object_rs->reset;

    while ( my $object = $object_rs->next ) {
        _add_to_indexer( $object, $indexer );
    }
}

sub _add_to_indexer {
    my ( $object, $indexer ) = @_;

    my $doc = {
        id => $object->id,
    };

    # TO DO: for authority names and controlled vocabularies, use the
    # longer text rather than the stringified text, e.g. notes,
    # description, language_name.

    for my $field ( @object_text_fields ) {
        $doc->{ $field } = $object->$field || $EMPTY_FIELD_VALUE;
    }



    # TO DO: inspect columns_info to get the field lists?
    my $type_obj = $object->type_object;
    if ( $object->type eq 'collection' ) {
        for my $field ( @collection_text_fields ) {
            $doc->{ $field } = $type_obj->$field || $EMPTY_FIELD_VALUE;
        }
        for my $field ( @collection_multitext_fields ) {
            $doc->{ $field } = join "\n", $type_obj->$field;
        }
    }
    elsif ( $object->type eq 'series' ) {
        for my $field ( @series_text_fields ) {
            $doc->{ $field } = $type_obj->$field || $EMPTY_FIELD_VALUE;
        }
    }
    elsif ( $object->type eq 'item' ) {
        for my $field ( @item_text_fields ) {
            $doc->{ $field } = $type_obj->$field || $EMPTY_FIELD_VALUE;
        }
        for my $field ( @item_multitext_fields ) {
            $doc->{ $field } = join "\n", $type_obj->$field;
        }

        my $item = $object->result_source->schema
                   ->resultset( 'Item' )
                   ->find( $object->id );

        # Now we index fields specific to item subclass objects, of which this item
        # might contain any number.
        # We call the classes() method to get all these objects, then iterate over
        # them, calling a different indexing subroutine depending upon the flavor
        # of subclass.
        my @classed_objects = $item->classes;
        for my $classed_object ( @classed_objects ) {
            my $perl_class = ref $classed_object;
            my ($class_suffix) = $perl_class =~ /^.*::(.*?)$/;
            $class_suffix = decamelize( $class_suffix );
            my $method = '_index_' . $class_suffix;

            my $index_ref = eval "$method( \$classed_object )";
            if ( $@ ) {
                die $@;
            }
            for my $field ( keys ( %{ $index_ref } ) ) {
                my $value = $index_ref->{ $field } || $EMPTY_FIELD_VALUE;
                if ( exists $doc->{ $field } ) {
                    $doc->{ $field } .= "\n$value";
                }
                else {
                    $doc->{ $field } = $value;
                }
            }
        }
    }

    $indexer->add_doc( $doc );
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_digital_object {
    my ( $item ) = @_;

    my $index_ref = {
        permanent_url => $item->permanent_url,
    };

    _add_location_to_index_ref( $item, $index_ref );

    if ( $item->format ) {
        $index_ref->{ format } = $item->format;
    }

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_audio_visual_media {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_bound_volume {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_browsing_object {
    my ( $item ) = @_;

    my $index_ref = {
        browsing_object_pid           => $item->pid,
        browsing_object_thumbnail_pid => $item->thumbnail_pid,
    };

    # (Browsing objects have no location info...)

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_container {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_document {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_file_folder {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_physical_image {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by _add_to_indexer, when indexing an item of this subclass.
sub _index_three_dimensional_object {
    my ( $item ) = @_;

    my $index_ref = {

    };

    _add_location_to_index_ref( $item, $index_ref );

    return $index_ref;
}

# Called by various of the item-subclass-indexing subroutines defined above.
sub _add_location_to_index_ref {
    my ( $item, $index_ref ) = @_;

    $index_ref->{ barcode } = $item->location->barcode;

    for my $title_object ( $item->location->titles ) {
        $index_ref->{ location_title } ||= '';
        if ( length $title_object->title ) {
            $index_ref->{ location_title } .= $title_object->title;
        }
        else {
            $index_ref->{ location_title } .= $EMPTY_FIELD_VALUE;
        }
    }
}

sub _remove_rs_from_indexer {
    my ( $object_rs, $indexer ) = @_;

    $object_rs->reset;

    while ( my $object = $object_rs->next ) {
        _remove_from_indexer( $object, $indexer );
    }
}

sub _remove_from_indexer {
    my ( $object, $indexer ) = @_;

    $indexer->delete_by_term(
        field => 'id',
        term => '' . $object->id,
    );
}

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

__PACKAGE__->meta->make_immutable;

1;
