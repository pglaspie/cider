package CIDER::Schema::Result::RecordContextType;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextType

=cut

__PACKAGE__->table( 'record_context_type' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    record_contexts =>
        'CIDER::Schema::Result::RecordContext',
    'rc_type',
    { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar', size => 20 },
);
__PACKAGE__->add_unique_constraint( [ 'name' ] );
use overload '""' => sub { shift->name() }, fallback => 1;

1;
