package CIDER::Logic::Indexer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp;

use KinoSearch;

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
    isa => 'Maybe[KinoSearch::Index::Indexer]',
);

has _in_txn => (
    is => 'rw',
    isa => 'Bool',
);

# Create the index schema.
# We'll try to have all the indexes share the same one...
my $index_schema = KinoSearch::Plan::Schema->new;
my $polyanalyzer = KinoSearch::Analysis::PolyAnalyzer->new(
    language => 'en',
);

# Define some basic types. Just being coarse for now.
my $text_type = KinoSearch::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 1,
);

my $unstored_text = KinoSearch::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 0,
    stored   => 0,
);

my $string_type = KinoSearch::Plan::StringType->new( sortable => 1 );
my $storage_only = KinoSearch::Plan::StringType->new( indexed => 0 );
my $index_only = KinoSearch::Plan::StringType->new( stored => 0 );
my $int_type    = KinoSearch::Plan::Int32Type->new;

# Define the fields.
my @text_fields = qw(
                        accession_by
                        accession_number
                        accession_procedure
                        arrangement
                        checksum
                        checksum_app
                        creator
                        corporate_name
                        description
                        file_extension
                        format
                        funder
                        geographic_term
                        handle
                        history
                        lc_class
                        media_app
                        notes
                        number
                        organization
                        original_filename
                        other_app
                        permanent_url
                        personal_name
                        pid
                        processing_notes
                        processing_status
                        publication_status
                        restrictions
                        rsa
                        stabilization_by
                        stabilization_notes
                        stabilization_procedure
                        technical_metadata
                        title
                        toc
                        topic_term
                        type
                        virus_app
                );

for my $field ( @text_fields ) {
    $index_schema->spec_field( name => $field, type => $text_type );
}

$index_schema->spec_field( name => 'id', type => $string_type );
$index_schema->spec_field( name => 'set', type => $unstored_text );


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

    my $indexer = KinoSearch::Index::Indexer->new(
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
        $indexer = KinoSearch::Index::Indexer->new(
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
        id => $object->id || '',
    };

    for my $field ( @text_fields ) {
        $doc->{ $field } = $object->$field || '';
    }

    my @sets = $object->sets;
    my $sets = join ' ', map { $_->id } @sets;
    $doc->{ set } = $sets || '';

    $indexer->add_doc( $doc );
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

__PACKAGE__->meta->make_immutable;

1;
