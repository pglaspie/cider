package CIDER::Schema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("user_roles");

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "role_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("user_id", "role_id");

__PACKAGE__->belongs_to(role => 'CIDER::Schema::Result::Role', 'role_id');

1;

