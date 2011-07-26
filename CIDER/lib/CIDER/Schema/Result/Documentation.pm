package CIDER::Schema::Result::Documentation;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Documentation

=cut

__PACKAGE__->table( 'documentation' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    collections => 'CIDER::Schema::Result::Collection',
    undef,
    { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar', size => 3 },
);
__PACKAGE__->add_unique_constraint( [ 'name' ] );
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    description =>
        { data_type => 'text' },
);

1;
