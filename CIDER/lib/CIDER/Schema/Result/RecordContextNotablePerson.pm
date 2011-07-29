package CIDER::Schema::Result::RecordContextNotablePerson;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextNotablePerson

=cut

__PACKAGE__->table( 'record_context_notable_person' );

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
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

1;
