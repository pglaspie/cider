package CIDER::Schema::Result::RecordContextOccupation;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextOccupation

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'record_context_occupation' );

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

__PACKAGE__->has_many(
    titles =>
        'CIDER::Schema::Result::OccupationTitle',
    'occupation',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', size => 10 },
    date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for $self->titles;

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

    $self->update_dates_from_xml_hashref( $hr, 'date' );

    $self->update_or_insert;

    $self->update_has_many_from_xml_hashref( $hr, titles => 'title' );

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
