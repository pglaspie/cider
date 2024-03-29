package CIDER::Schema::Result::Collection;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

use Carp;

=head1 NAME

CIDER::Schema::Result::Collection

=cut

__PACKAGE__->load_components( 'UpdateFromXML', 'DerivedElements' );

__PACKAGE__->table( 'collection' );

__PACKAGE__->resultset_class( 'CIDER::Schema::Base::ResultSet::TypeObject' );

__PACKAGE__->setup_object;

__PACKAGE__->add_columns(
    bulk_date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    bulk_date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

__PACKAGE__->add_columns(
    scope =>
        { data_type => 'text', is_nullable => 1 },
    organization =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    collection_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
);
__PACKAGE__->many_to_many(
    record_contexts =>
        'collection_record_contexts',
    'record_context',
);

__PACKAGE__->has_many(
    collection_primary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    undef,
    { where => { is_primary => 1 } }
);
__PACKAGE__->many_to_many(
    primary_record_contexts =>
        'collection_primary_record_contexts',
    'record_context',
);

__PACKAGE__->has_many(
    collection_secondary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    undef,
    { where => { is_primary => 0 } }
);
__PACKAGE__->many_to_many(
    secondary_record_contexts =>
        'collection_secondary_record_contexts',
    'record_context',
);

__PACKAGE__->add_columns(
    history =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    documentation =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    documentation =>
        'CIDER::Schema::Result::Documentation',
);

__PACKAGE__->add_columns(
    processing_notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    material =>
        'CIDER::Schema::Result::CollectionMaterial',
);

__PACKAGE__->add_columns(
    notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    languages =>
        'CIDER::Schema::Result::CollectionLanguage',
);

__PACKAGE__->has_many(
    subjects =>
        'CIDER::Schema::Result::CollectionSubject',
);

__PACKAGE__->add_columns(
    processing_status =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    processing_status =>
        'CIDER::Schema::Result::ProcessingStatus',
);

__PACKAGE__->add_columns(
    permanent_url =>
        { data_type => 'varchar', is_nullable => 1, size => 1024 },
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar', is_nullable => 1, size => 255 },
);
__PACKAGE__->add_unique_constraint( [ qw( pid ) ] );

__PACKAGE__->add_columns(
    publication_status =>
        { data_type => 'tinyint', is_foreign_key => 1, default_value => 1 },
);
__PACKAGE__->belongs_to(
    publication_status =>
        'CIDER::Schema::Result::PublicationStatus',
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    collection_relationships =>
        'CIDER::Schema::Result::CollectionRelationship',
);


=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'collection';
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $_->delete for (
        $self->collection_record_contexts,
        $self->material,
        $self->languages,
        $self->subjects,
        $self->collection_relationships,
    );

    $self->next::method( @_ );

    return $self;
}

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->object->update_from_xml( $elt, $hr );

    # Text elements

    $self->update_dates_from_xml_hashref(
        $hr, 'bulk_date' );
    $self->update_text_from_xml_hashref(
        $hr, 'scope' );
    $self->update_text_from_xml_hashref(
        $hr, 'organization' );
    $self->update_text_from_xml_hashref(
        $hr, 'history' );
    $self->update_text_from_xml_hashref(
        $hr, 'processing_notes' );
    $self->update_text_from_xml_hashref(
        $hr, 'notes' );
    $self->update_text_from_xml_hashref(
        $hr, permanent_url => 'permanentURL' );
    $self->update_text_from_xml_hashref(
        $hr, 'pid' );

    # Controlled vocabulary elements

    $self->update_cv_from_xml_hashref(
        $hr, 'documentation' );
    $self->update_cv_from_xml_hashref(
        $hr, 'processing_status' );
    $self->update_cv_from_xml_hashref(
        $hr, 'publication_status' );

    $self->update_or_insert;

    # Repeatables - These have to be done after the row is inserted,
    # so that its id can be used as a foreign key.

    $self->update_has_many_from_xml_hashref(
        $hr, material => 'material', 'associatedMaterial' );

    $self->update_has_many_from_xml_hashref(
        $hr, languages => 'language' );

    # If languages were not set, or removed, set the language to English.
    if ( $self->languages == 0 ) {
        $self->add_to_languages( { language => 'eng' } );
    }

    $self->update_has_many_from_xml_hashref(
        $hr, subjects => 'subject' );

    my $schema = $self->result_source->schema;

    if ( exists( $hr->{ recordContexts } ) ) {
        $self->collection_record_contexts->delete;
        if ( my $elts = $hr->{ recordContexts } ) {
            my $rs = $schema->resultset( 'RecordContext' );
            for my $rcs_elt ( @$elts ) {
                my $rel = 'collection_' . $rcs_elt->tagName . '_record_contexts';
                for my $rc_elt ( $rcs_elt->getChildrenByTagName( '*' ) ) {
                    my $id = $rc_elt->textContent;
                    my $rc = $rs->find( { record_id => $id } );
                    croak "There is no record context '$id'." unless $rc;
                    $self->create_related( $rel, { record_context => $rc } );
                }
            }
        }
    }

    $self->update_relationships_from_xml_hashref( $hr );

    $self->update_audit_trail_from_xml_hashref( $hr );

    return $self;
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

1;
