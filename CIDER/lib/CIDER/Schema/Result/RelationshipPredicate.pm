package CIDER::Schema::Result::RelationshipPredicate;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RelationshipPredicate

=cut

__PACKAGE__->table("relationship_predicate");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 predicate

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "predicate",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 collection_relationships

Type: has_many

Related object: L<CIDER::Schema::Result::CollectionRelationship>

=cut

__PACKAGE__->has_many(
    collection_relationships => 'CIDER::Schema::Result::CollectionRelationship',
    'predicate',
    { cascade_copy => 0, cascade_delete => 0 },
);

1;
