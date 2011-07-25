package CIDER::Schema::Result::Collection;

use strict;
use warnings;

use base 'CIDER::Schema::Base::TypeObject';
use Locale::Language;

=head1 NAME

CIDER::Schema::Result::Collection

=cut

__PACKAGE__->table( 'collection' );

__PACKAGE__->setup_object;

__PACKAGE__->add_column(
  "bulk_date_from",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "bulk_date_to",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "record_context",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "history",
  { data_type => "text", is_nullable => 1 },
  "scope",
  { data_type => "text", is_nullable => 1 },
  "organization",
  { data_type => "text", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "language",
  { data_type => "char", is_nullable => 0, size => 3, default_value => 'eng' },
  "processing_status",
  { data_type => "tinyint", is_foreign_key => 1 },
  "processing_notes",
  { data_type => "text", is_nullable => 1 },
  "has_physical_documentation",
  { data_type => "enum", extra => { list => [0, 1] } },
  "permanent_url",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "pid",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "publication_status",
  { data_type => "varchar", is_nullable => 1, size => 16 },
);

__PACKAGE__->belongs_to(
  "record_context",
  "CIDER::Schema::Result::RecordContext",
  { id => "record_context" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
  "processing_status",
  "CIDER::Schema::Result::ProcessingStatus",
  { id => "processing_status" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

__PACKAGE__->has_many(
    collection_relationships => 'CIDER::Schema::Result::CollectionRelationship',
    'collection',
);

__PACKAGE__->has_many(
    material => 'CIDER::Schema::Result::CollectionMaterial',
    'collection',
);

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'collection';
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $_->delete for ( $self->collection_relationships,
                     $self->material );

    $self->next::method( @_ );

    return $self;
}

=head2 language_name

Returns the full English name of the language of a collection.  (As
opposed to the 'language' field, which contains the three-letter ISO
language code.)

=cut

sub language_name {
    my $self = shift;

    return code2language( $self->language, LOCALE_LANG_ALPHA_3 );
}

1;
