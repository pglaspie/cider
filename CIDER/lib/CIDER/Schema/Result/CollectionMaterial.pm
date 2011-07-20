package CIDER::Schema::Result::CollectionMaterial;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::CollectionMaterial

=cut

__PACKAGE__->table("collection_material");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 collection

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 material

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "collection",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "material",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

use overload '""' => sub { shift->material() }, fallback => 1;

=head1 RELATIONS

=head2 collection

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  collection => "CIDER::Schema::Result::Object",
  { id => "collection" },
  {
    is_deferrable => 1,
    on_delete     => undef,
    on_update     => undef,
  },
);

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection );

    return $self;
}

sub delete {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection );

    return $self;
}

1;
