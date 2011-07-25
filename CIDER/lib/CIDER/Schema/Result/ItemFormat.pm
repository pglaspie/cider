package CIDER::Schema::Result::ItemFormat;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::ItemFormat

=cut

__PACKAGE__->table("item_format");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->has_many(
  "items",
  "CIDER::Schema::Result::Item",
  { "foreign.format" => "self.id" },
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
