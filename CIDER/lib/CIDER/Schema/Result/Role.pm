package CIDER::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
                         );

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=cut
    
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role",
  { data_type => "text", is_nullable => 1, size => 64 },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
  "user_roles",
  "CIDER::Schema::Result::UserRole",
  { "foreign.owner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
