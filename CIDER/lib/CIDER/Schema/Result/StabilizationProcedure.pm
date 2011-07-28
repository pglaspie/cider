package CIDER::Schema::Result::StabilizationProcedure;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::StabilizationProcedure

=cut

__PACKAGE__->table( 'stabilization_procedure' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    'stabilization_procedure',
    { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    code =>
        { data_type => 'varchar', size => 10 },
);
__PACKAGE__->add_unique_constraint( [ 'code' ] );
use overload '""' => sub { shift->code() }, fallback => 1;

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar', is_nullable => 1 },
);

1;
