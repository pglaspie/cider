package CIDER::Schema::Result::RecordContextRelationshipType;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextRelationshipType

=cut

__PACKAGE__->table( 'record_context_relationship_type' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    record_context_relationships =>
        'CIDER::Schema::Result::RecordContextRelationship',
    'type',
    { cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'name' ] );
use overload '""' => sub { shift->name }, fallback => 1;

1;
