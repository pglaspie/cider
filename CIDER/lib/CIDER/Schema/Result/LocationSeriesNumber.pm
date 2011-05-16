package CIDER::Schema::Result::LocationSeriesNumber;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::LocationSeriesNumber;

=cut

__PACKAGE__->table("location_series_number");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 location

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=head2 number

  data_type: 'char'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "location",
    { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 16 },
    "number",
    { data_type => "char", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->number() }, fallback => 1;

1;
