package CIDER::Schema::Result::Log;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::Log

=cut

__PACKAGE__->table("log");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 action

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 timestamp

  data_type: 'datetime'
  is_nullable: 1

=head2 user

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 object

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "action",
  { data_type => "char", is_nullable => 1, size => 16 },
  "timestamp",
  { data_type => "datetime", is_nullable => 1 },
  "user",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "object",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<CIDER::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CIDER::Schema::Result::User",
  { id => "user" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-03 13:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OPE99PEQClEQeRhioXdv/Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
