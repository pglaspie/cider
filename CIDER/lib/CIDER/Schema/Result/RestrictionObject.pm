package CIDER::Schema::Result::RestrictionObject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::RestrictionObject

=cut

__PACKAGE__->table("restriction_object");

=head1 ACCESSORS

=head2 restriction

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 object

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "restriction",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "object",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
);
__PACKAGE__->set_primary_key("restriction", "object");

=head1 RELATIONS

=head2 object

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  "object",
  "CIDER::Schema::Result::Object",
  { id => "object" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 restriction

Type: belongs_to

Related object: L<CIDER::Schema::Result::Restriction>

=cut

__PACKAGE__->belongs_to(
  "restriction",
  "CIDER::Schema::Result::Restriction",
  { id => "restriction" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-12-03 13:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8YjlC+Qkg8cEsKBuj15+5g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
