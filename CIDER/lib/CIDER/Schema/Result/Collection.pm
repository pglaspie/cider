package CIDER::Schema::Result::Collection;

use strict;
use warnings;

use base 'CIDER::Schema::Base::TypeObject';

=head1 NAME

CIDER::Schema::Result::Collection

=cut

__PACKAGE__->table( 'collection' );

__PACKAGE__->setup_object;

__PACKAGE__->add_columns(
    bulk_date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    bulk_date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

__PACKAGE__->add_columns(
    scope =>
        { data_type => 'text', is_nullable => 1 },
    organization =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    collection_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
);
__PACKAGE__->many_to_many(
    record_contexts =>
        'collection_record_contexts',
    'record_context',
);

__PACKAGE__->has_many(
    collection_primary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    undef,
    { where => { is_primary => 1 } }
);
__PACKAGE__->many_to_many(
    primary_record_contexts =>
        'collection_primary_record_contexts',
    'record_context',
);

__PACKAGE__->has_many(
    collection_secondary_record_contexts =>
        'CIDER::Schema::Result::CollectionRecordContext',
    undef,
    { where => { is_primary => 0 } }
);
__PACKAGE__->many_to_many(
    secondary_record_contexts =>
        'collection_secondary_record_contexts',
    'record_context',
);

__PACKAGE__->add_columns(
    history =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    documentation =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    documentation =>
        'CIDER::Schema::Result::Documentation',
);

__PACKAGE__->add_columns(
    processing_notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    material =>
        'CIDER::Schema::Result::CollectionMaterial',
);

__PACKAGE__->add_columns(
    notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    languages =>
        'CIDER::Schema::Result::CollectionLanguage',
);

__PACKAGE__->has_many(
    subjects =>
        'CIDER::Schema::Result::CollectionSubject',
);

__PACKAGE__->add_columns(
    processing_status =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    processing_status =>
        'CIDER::Schema::Result::ProcessingStatus',
);

__PACKAGE__->add_columns(
    permanent_url =>
        { data_type => 'varchar', is_nullable => 1, size => 1024 },
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar', is_nullable => 1, size => 255 },
);
__PACKAGE__->add_unique_constraint( [ qw( pid ) ] );

__PACKAGE__->add_columns(
    publication_status =>
        { data_type => 'tinyint', is_foreign_key => 1, default_value => 1 },
);
__PACKAGE__->belongs_to(
    publication_status =>
        'CIDER::Schema::Result::PublicationStatus',
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    collection_relationships =>
        'CIDER::Schema::Result::CollectionRelationship',
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

    $_->delete for (
        $self->material,
        $self->languages,
        $self->subjects,
        $self->collection_relationships,
    );

    $self->next::method( @_ );

    return $self;
}

1;
