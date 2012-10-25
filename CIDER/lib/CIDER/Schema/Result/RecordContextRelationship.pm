package CIDER::Schema::Result::RecordContextRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use Carp;

=head1 NAME

CIDER::Schema::Result::RecordContextRelationship;

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'record_context_relationship' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    record_context =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    record_context =>
        'CIDER::Schema::Result::RecordContext',
);

__PACKAGE__->add_columns(
    type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    type =>
        'CIDER::Schema::Result::RecordContextRelationshipType',
);

__PACKAGE__->add_columns(
    related_entity =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    related_entity =>
        'CIDER::Schema::Result::RecordContext',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', size => 10, is_nullable => 1 },
    date_to =>
        { data_type => 'varchar', size => 10, is_nullable => 1 },
);

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    my $src = $self->result_source;

    my $type_rs = $src->related_source( 'type' )->resultset;
    my $type = $type_rs->find( { name => $elt->getAttribute( 'type' ) } );
    $self->type( $type );

    my $rc_rs = $src->related_source( 'related_entity' )->resultset;
    my $id = $hr->{ relatedEntity };
    my $rc = $rc_rs->find( { record_id => $id } );
    unless ( $rc ) {
        croak "Record context related entity '$id' does not exist.";
    }
    $self->related_entity( $rc );

    $self->update_dates_from_xml_hashref( $hr, 'date' );

    return $self->update_or_insert;
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
