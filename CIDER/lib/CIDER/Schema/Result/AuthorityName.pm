package CIDER::Schema::Result::AuthorityName;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::AuthorityName

=cut

__PACKAGE__->table("authority_name");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 note

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "note",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->name() }, fallback => 1;

=head1 RELATIONS

=head2 item_personal_names

Type: has_many

Related object: L<CIDER::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "item_personal_names",
  "CIDER::Schema::Result::Item",
  { "foreign.personal_name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 item_corporate_names

Type: has_many

Related object: L<CIDER::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "item_corporate_names",
  "CIDER::Schema::Result::Item",
  { "foreign.corporate_name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 item_creator

Type: has_many

Related object: L<CIDER::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "item_creators",
  "CIDER::Schema::Result::Item",
  { "foreign.creator" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 items

Type: has_many

Related object: L<CIDER::Schema::Result::Item>

A resultset of all items that have this authority name in any field.

=cut

__PACKAGE__->has_many(
  "items",
  "CIDER::Schema::Result::Item",
  [
      { "foreign.personal_name" => "self.id" },
      { "foreign.corporate_name" => "self.id" },
      { "foreign.creator" => "self.id" },
  ],
  { cascade_copy => 0, cascade_delete => 0 },
);


sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
