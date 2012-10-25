package CIDER::Schema::Result::Location;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use XML::LibXML;
use Carp;

=head1 NAME

CIDER::Schema::Result::Location;

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'location' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    titles =>
        'CIDER::Schema::Result::LocationTitle',
);

__PACKAGE__->has_many(
    collection_numbers =>
        'CIDER::Schema::Result::LocationCollectionNumber',
);

__PACKAGE__->has_many(
    series_numbers =>
        'CIDER::Schema::Result::LocationSeriesNumber',
);

__PACKAGE__->add_columns(
    barcode =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'barcode' ] );
use overload '""' => sub { shift->barcode }, fallback => 1;

__PACKAGE__->add_columns(
    unit_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    unit_type =>
        'CIDER::Schema::Result::UnitType',
    undef,
    { proxy => 'volume' }
);

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->update_cv_from_xml_hashref(
        $hr, unit_type => 'name' );

    $self->update_or_insert;

    $self->update_has_many_from_xml_hashref(
        $hr, titles => 'title' );
    $self->update_has_many_from_xml_hashref(
        $hr, collection_numbers => 'number' );
    $self->update_has_many_from_xml_hashref(
        $hr, series_numbers => 'number' );

    return $self;
}

sub name_and_note {
    my $self = shift;
    return $self->barcode;
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
