package CIDER::Schema::Result::RecordContext;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContext

=cut

__PACKAGE__->table( 'record_context' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    collection_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
);
__PACKAGE__->many_to_many(
    collections =>
        'collection_record_contexts',
    'collection',
);

__PACKAGE__->has_many(
    collection_primary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
    { where => { is_primary => 1 } }
);
__PACKAGE__->many_to_many(
    primary_collections =>
        'collection_primary_record_contexts',
    'collection',
);

__PACKAGE__->has_many(
    collection_secondary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    'record_context',
    { where => { is_primary => 0 } }
);
__PACKAGE__->many_to_many(
    secondary_collections =>
        'collection_secondary_record_contexts',
    'collection',
);


__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar', is_nullable => 0, size => 128 },
);

1;
