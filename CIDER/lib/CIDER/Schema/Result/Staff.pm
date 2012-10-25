package CIDER::Schema::Result::Staff;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Staff

=cut

__PACKAGE__->table( 'staff' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    { 'foreign.stabilized_by' => 'self.id' },
);

__PACKAGE__->many_to_many(
    items =>
        'digital_objects',
    'item'
);

__PACKAGE__->has_many(
    logs =>
        'CIDER::Schema::Result::Log',
);

__PACKAGE__->might_have(
    user =>
        'CIDER::Schema::Result::User',
);

__PACKAGE__->add_columns(
    first_name =>
        { data_type => 'varchar' },
    last_name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->full_name }, fallback => 1;

sub full_name {
    my $self = shift;
    return $self->last_name . ', ' . $self->first_name;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

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
