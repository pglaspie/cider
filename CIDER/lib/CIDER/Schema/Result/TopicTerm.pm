package CIDER::Schema::Result::TopicTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::TopicTerm

=cut

__PACKAGE__->table("topic_term");

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

__PACKAGE__->has_many(
  "items",
  "CIDER::Schema::Result::Item",
  { "foreign.topic_term" => "self.id" },
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
