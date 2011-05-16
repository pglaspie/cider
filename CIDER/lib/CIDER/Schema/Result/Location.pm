package CIDER::Schema::Result::Location;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Location;

=cut

__PACKAGE__->table("location");

=head1 ACCESSORS

=head2 barcode

  data_type: 'char'
  is_nullable: 0
  size: 16

=head2 unit_type

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "barcode",
  { data_type => "char", is_nullable => 0, size => 16 },
  "unit_type",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("barcode");

=head1 RELATIONS

=head2 unit_type

Type: belongs_to

Related object: L<CIDER::Schema::Result::LocationUnitType>

=cut

__PACKAGE__->belongs_to(
    unit_type => 'CIDER::Schema::Result::LocationUnitType',
    undef,
    { proxy => 'volume' }
);

=head2 items

Type: has_many

Related object: L<CIDER::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
    items => 'CIDER::Schema::Result::Item',
    undef,
    { cascade_delete => 0, cascade_copy => 0 }
);

=head2 titles

Type: has_many

Related object: L<CIDER::Schema::Result::LocationTitle>

=cut

__PACKAGE__->has_many(
    titles => 'CIDER::Schema::Result::LocationTitle',
);

1;
