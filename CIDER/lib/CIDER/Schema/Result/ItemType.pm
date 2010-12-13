package CIDER::Schema::Result::ItemType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::ItemType

=cut

__PACKAGE__->table("item_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 objects

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "objects",
  "CIDER::Schema::Result::Object",
  { "foreign.type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-03 13:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hIlxR5Nt+DmLSScikImLwQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
