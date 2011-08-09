package CIDER::Schema::Result::UnitType;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::UnitType;

=cut

__PACKAGE__->table( 'unit_type' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    locations =>
        'CIDER::Schema::Result::Location',
    'unit_type',
    { cascade_copy => 0, cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'name' ] );
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    volume =>
        { data_type => 'decimal', is_nullable => 1, size => [5, 2] },
);

1;
