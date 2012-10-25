package CIDER::Schema::Result::Series;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

=head1 NAME

CIDER::Schema::Result::Series

=cut

__PACKAGE__->load_components( 'UpdateFromXML', 'DerivedElements' );

__PACKAGE__->table( 'series' );

__PACKAGE__->resultset_class( 'CIDER::Schema::Base::ResultSet::TypeObject' );

__PACKAGE__->setup_object;

__PACKAGE__->add_columns(
    bulk_date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    bulk_date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    description =>
        { data_type => 'text', is_nullable => 1 },
    arrangement =>
        { data_type => 'text', is_nullable => 1 },
    notes =>
        { data_type => 'text', is_nullable => 1 },
);

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'series';
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

    $self->update_dates_from_xml_hashref(
        $hr, 'bulk_date' );
    $self->update_text_from_xml_hashref(
        $hr, 'description' );
    $self->update_text_from_xml_hashref(
        $hr, 'arrangement' );
    $self->update_text_from_xml_hashref(
        $hr, 'notes' );

    $self->update_or_insert;

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
