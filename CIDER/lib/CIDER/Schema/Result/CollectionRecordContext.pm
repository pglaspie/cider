package CIDER::Schema::Result::CollectionRecordContext;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::CollectionRecordContext

=cut

__PACKAGE__->table( 'collection_record_context' );

__PACKAGE__->add_columns(
    collection =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    collection =>
        'CIDER::Schema::Result::Collection',
);

__PACKAGE__->add_columns(
    is_primary =>
        { data_type => 'boolean' },
);

__PACKAGE__->add_columns(
    record_context =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    record_context =>
        'CIDER::Schema::Result::RecordContext',
);

__PACKAGE__->set_primary_key( qw( collection is_primary record_context ) );

1;
