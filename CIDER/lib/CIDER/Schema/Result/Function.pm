package CIDER::Schema::Result::Function;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Function

=cut

__PACKAGE__->table( 'function' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    record_contexts =>
        'CIDER::Schema::Result::RecordContext',
    undef,
    { cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

1;
