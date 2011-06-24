package CIDER::Schema::Result::CollectionRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::CollectionRelationship;

=cut

__PACKAGE__->table("collection_relationship");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 collection

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 predicate

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 pid

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "collection",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    "predicate",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    "pid",
    { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head2 collection

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
    collection => "CIDER::Schema::Result::Object",
    'collection',
);

=head2 predicate

Type: belongs_to

Related object: L<CIDER::Schema::Result::RelationshipPredicate>

=cut

__PACKAGE__->belongs_to(
    predicate => "CIDER::Schema::Result::RelationshipPredicate",
    'predicate',
);


1;
