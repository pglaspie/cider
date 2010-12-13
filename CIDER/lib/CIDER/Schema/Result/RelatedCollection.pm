package CIDER::Schema::Result::RelatedCollection;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::RelatedCollection

=cut

__PACKAGE__->table("related_collection");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 object

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 custodian

  data_type: 'char'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "object",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "custodian",
  { data_type => "char", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-03 13:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jm8sIryGCe8h+61I6Y56hw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
