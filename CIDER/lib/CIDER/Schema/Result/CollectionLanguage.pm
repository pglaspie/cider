package CIDER::Schema::Result::CollectionLanguage;

use strict;
use warnings;

use base 'DBIx::Class::Core';
use Locale::Language;

=head1 NAME

CIDER::Schema::Result::CollectionLanguage

=cut

__PACKAGE__->load_components( 'ConvertEmptyToNull' );

__PACKAGE__->table( 'collection_language' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    collection =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    collection =>
        'CIDER::Schema::Result::Collection',
);

__PACKAGE__->add_columns(
    language =>
        { data_type => 'char', size => 3 },
);
use overload '""' => sub { shift->language() }, fallback => 1;

=head1 METHODS

=cut

=head2 language_name

Returns the full English name of a collection language.  (As opposed
to the 'language' field, which contains the three-letter ISO language
code.)

=cut

sub language_name {
    my $self = shift;

    return code2language( $self->language, LOCALE_LANG_ALPHA_3 );
}

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub delete {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

1;
