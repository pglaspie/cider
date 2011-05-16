package CIDER::Schema::Result::LocationUnitType;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::LocationUnitType;

=cut

__PACKAGE__->table("location_unit_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  is_nullable: 0
  size: 255

=head2 volume

  data_type: 'decimal'
  is_nullable: 1,
  size: [5, 2]

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "name",
    { data_type => "char", is_nullable => 0, size => 255 },
    "volume",
    { data_type => "decimal", is_nullable => 1, size => [5, 2] },
);
__PACKAGE__->set_primary_key("id");

1;
