package CIDER::Schema::Result::RecordContext;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContext

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'record_context' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    collection_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
);
__PACKAGE__->many_to_many(
    collections =>
        'collection_record_contexts',
    'collection',
);

__PACKAGE__->has_many(
    collection_primary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
    { where => { is_primary => 1 } }
);
__PACKAGE__->many_to_many(
    primary_collections =>
        'collection_primary_record_contexts',
    'collection',
);

__PACKAGE__->has_many(
    collection_secondary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
    { where => { is_primary => 0 } }
);
__PACKAGE__->many_to_many(
    secondary_collections =>
        'collection_secondary_record_contexts',
    'collection',
);

__PACKAGE__->add_columns(
    record_id =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'record_id' ] );
use overload '""' => sub { shift->record_id }, fallback => 1;

__PACKAGE__->add_columns(
    publication_status =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    publication_status =>
        'CIDER::Schema::Result::PublicationStatus',
);

__PACKAGE__->add_columns(
    name_entry =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'name_entry' ] );

__PACKAGE__->add_columns(
    rc_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    rc_type =>
        'CIDER::Schema::Result::RecordContextType',
);

__PACKAGE__->has_many(
    alt_names =>
        'CIDER::Schema::Result::RecordContextAlternateName',
    'record_context',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    circa =>
        { data_type => 'boolean', default_value => 0 },
    ongoing =>
        { data_type => 'boolean', default_value => 0 },
);

__PACKAGE__->add_columns(
    abstract =>
        { data_type => 'text', is_nullable => 1 },
    history =>
        { data_type => 'text', is_nullable => 1 },
    structure_notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    context =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    sources =>
        'CIDER::Schema::Result::RecordContextSource',
    'record_context',
);

__PACKAGE__->add_columns(
    function =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    function =>
        'CIDER::Schema::Result::Function',
);

__PACKAGE__->has_many(
    occupations =>
        'CIDER::Schema::Result::RecordContextOccupation',
    'record_context',
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    record_context_relationships =>
        'CIDER::Schema::Result::RecordContextRelationship',
    'record_context',
);

__PACKAGE__->add_columns(
    audit_trail =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    audit_trail =>
        'CIDER::Schema::Result::AuditTrail',
    undef,
    { cascade_delete => 1 }
);


=head2 store_column( $column, $value )

Override store_column to set default values.

=cut

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    # Convert all empty strings to nulls.
    $value = undef if defined( $value ) && $value eq '';

    unless ( defined( $value ) ) {
        if ( $column eq 'rc_type' ) {
            my $rs = $self->result_source->related_source( $column )->resultset;
            $value = $rs->find( { name => 'corporateBody' } )->id;
        }
        elsif ( $column eq 'circa' || $column eq 'ongoing' ) {
            $value = 0;
        }
    }

    return $self->next::method( $column, $value );
}

=head2 insert

Override insert to add an audit trail and set default values.

=cut

sub insert {
    my $self = shift;

    $self->rc_type( undef ) unless defined $self->rc_type;

    $self->audit_trail( $self->create_related( 'audit_trail', {} ) );
    $self->audit_trail->created_by( $self->result_source->schema->user->staff );

    $self->next::method( @_ );

    return $self;
}

=head2 update

Override update to add a modification log to the audit trail.

=cut

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->audit_trail->add_to_modification_logs( {
        staff => $self->result_source->schema->user->staff
    } );

    return $self;
}

=head2 export

Add an export log to the audit trail.

=cut

sub export {
    my $self = shift;

    $self->audit_trail->add_to_export_logs( {
        staff => $self->result_source->schema->user->staff
    } );
}

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for (
        $self->alt_names,
        $self->sources,
        $self->occupations,
        $self->record_context_relationships,
    );

    return $self->next::method( @_ );
}

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->update_cv_from_xml_hashref(
        $hr, 'publication_status' );
    $self->update_text_from_xml_hashref(
        $hr, 'name_entry' );
    $self->update_cv_from_xml_hashref(
        $hr, 'rc_type' );
    $self->update_dates_from_xml_hashref(
        $hr, 'date' );
    $self->update_boolean_from_xml_hashref(
        $hr, 'circa' );
    $self->update_boolean_from_xml_hashref(
        $hr, 'ongoing' );
    $self->update_text_from_xml_hashref(
        $hr, 'abstract' );
    $self->update_text_from_xml_hashref(
        $hr, 'history' );
    $self->update_text_from_xml_hashref(
        $hr, 'structure_notes' );
    $self->update_text_from_xml_hashref(
        $hr, 'context' );
    $self->update_term_from_xml_hashref(
        $hr, 'function' );

    $self->update_or_insert;

    # Repeatables - These have to be done after the row is inserted,
    # so that its id can be used as a foreign key.

    $self->update_has_many_from_xml_hashref(
        $hr, alt_names => 'name', 'alternateNames' );
    $self->update_has_many_from_xml_hashref(
        $hr, sources => 'source' );

    if ( exists( $hr->{ occupations } ) ) {
        $self->occupations->delete;
        for my $occ_elt ( @{ $hr->{ occupations } } ) {
            my $occ = $self->new_related( 'occupations', { } );
            $occ->update_from_xml( $occ_elt );
        }
    }

    if ( exists( $hr->{ relationships } ) ) {
        $self->record_context_relationships->delete;
        for my $rel_elt ( @{ $hr->{ relationships } } ) {
            my $rel = $self->new_related( 'record_context_relationships', { } );
            $rel->update_from_xml( $rel_elt );
        }
    }

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
