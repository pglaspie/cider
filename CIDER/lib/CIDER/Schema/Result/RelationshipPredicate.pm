package CIDER::Schema::Result::RelationshipPredicate;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RelationshipPredicate;

=cut

__PACKAGE__->table( 'relationship_predicate' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    collection_relationships =>
        'CIDER::Schema::Result::CollectionRelationship',
    'predicate',
    { cascade_copy => 0, cascade_delete => 0 }
);

__PACKAGE__->has_many(
    digital_object_relationships =>
        'CIDER::Schema::Result::DigitalObjectRelationship',
    { 'foreign.predicate' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 0 }
);

__PACKAGE__->has_many(
    browsing_object_relationships =>
        'CIDER::Schema::Result::BrowsingObjectRelationship',
    'predicate',
    { cascade_copy => 0, cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    predicate =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'predicate' ] );
use overload '""' => sub { shift->predicate() }, fallback => 1;

1;
