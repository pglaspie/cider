package CIDER::Schema::Result::ItemRestrictions;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::ItemRestrictions

=cut

__PACKAGE__->table("item_restrictions");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->has_many(
  "items",
  "CIDER::Schema::Result::Item",
  { "foreign.restrictions" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


1;
