package CIDER::Schema::Result::RecordContext;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::RecordContext

=cut

__PACKAGE__->table("record_context");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_nullable => 0 },
    "name",
    { data_type => "varchar", is_nullable => 0, size=>128 },
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
  { "foreign.record_creator" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
