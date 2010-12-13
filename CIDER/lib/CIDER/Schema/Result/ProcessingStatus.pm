package CIDER::Schema::Result::ProcessingStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::ProcessingStatus

=cut

__PACKAGE__->table("processing_status");

=head1 ACCESSORS

=head2 id

  data_type: 'tinyint'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "tinyint", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", is_nullable => 0, size => 32 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 object_processing_statuses

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "object_processing_statuses",
  "CIDER::Schema::Result::Object",
  { "foreign.processing_status" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 object_processing_statuses

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "object_processing_statuses",
  "CIDER::Schema::Result::Object",
  { "foreign.processing_status" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-03 13:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:93rDDC8yxe4eYrDn/sqkew


# You can replace this text with custom content, and it will be preserved on regeneration
1;
