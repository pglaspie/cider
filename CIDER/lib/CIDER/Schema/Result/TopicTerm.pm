package CIDER::Schema::Result::TopicTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::TopicTerm

=cut

__PACKAGE__->table("topic_term");

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

=head2 objects

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "objects",
  "CIDER::Schema::Result::Object",
  { "foreign.topic_term" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $object ( $self->objects ) {
        $self->result_source->schema->indexer->update( $object );
    }

    return $self;
}

1;
