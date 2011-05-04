package CIDER::Schema::Result::Log;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components( qw( InflateColumn::DateTime TimeStamp ) );

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
  { data_type => "char", is_nullable => 0, size => 16 },
  "timestamp",
  { data_type => "datetime", is_nullable => 0, set_on_create => 1 },
  "user",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "object",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=head2 object

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  "object",
  "CIDER::Schema::Result::Object",
  { id => "object" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

sub date {
    my $self = shift;

    return $self->timestamp->truncate( to => 'day' );
}

1;
