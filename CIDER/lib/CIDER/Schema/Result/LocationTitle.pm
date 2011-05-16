package CIDER::Schema::Result::LocationTitle;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::LocationTitle;

=cut

__PACKAGE__->table("location_title");

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

=head2 title

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "location",
    { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 16 },
    "title",
    { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->title() }, fallback => 1;

1;
