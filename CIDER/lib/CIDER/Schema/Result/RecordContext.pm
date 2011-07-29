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
    record_id =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'record_id' ] );

__PACKAGE__->add_columns(
    publication_status =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    publication_status =>
        'CIDER::Schema::Result::PublicationStatus',
);

__PACKAGE__->add_columns(
    name_entry =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'name_entry' ] );

__PACKAGE__->add_columns(
    rc_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    rc_type =>
        'CIDER::Schema::Result::RecordContextType',
);

__PACKAGE__->has_many(
    alt_names =>
        'CIDER::Schema::Result::RecordContextAlternateName',
    'record_context',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    circa =>
        { data_type => 'boolean', default_value => 0 },
    ongoing =>
        { data_type => 'boolean', default_value => 0 },
);

__PACKAGE__->add_columns(
    abstract =>
        { data_type => 'text', is_nullable => 1 },
    history =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    notable_persons =>
        'CIDER::Schema::Result::RecordContextNotablePerson',
    'record_context',
);

__PACKAGE__->add_columns(
    context =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    sources =>
        'CIDER::Schema::Result::RecordContextSource',
    'record_context',
);

__PACKAGE__->add_columns(
    function =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    function =>
        'CIDER::Schema::Result::Function',
);

__PACKAGE__->has_many(
    occupations =>
        'CIDER::Schema::Result::RecordContextOccupation',
    'record_context',
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    record_context_relationships =>
        'CIDER::Schema::Result::RecordContextRelationship',
    'record_context',
);

1;
