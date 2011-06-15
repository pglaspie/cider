package CIDER::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use KinoSearch;
use CIDER::Logic::Indexer;

has schema => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
);

has index => (
    is => 'ro',
    isa => 'Str'
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    my ( $c ) = @_;

    my $schema = $c->model( 'CIDERDB' )->schema;

    return $self->meta->clone_object( $self, schema => $schema );
}

sub indexer {
    my $self = shift;

    return CIDER::Logic::Indexer->new(
        schema => $self->schema,
        path_to_index => $self->index,
    );
}

sub searcher {
    my $self = shift;

    return KinoSearch::Search::IndexSearcher->new(
        index => $self->index,
    );
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CIDER::Model::Search - Catalyst Model

=head1 DESCRIPTION

Catalyst Model for searching the index.

=head1 METHODS

=head2 indexer

Returns an instance of L<CIDER::Logic::Indexer>.

=head2 searcher

Returns an instance of L<KinoSearch::Search::IndexSearcher>.  Note
that if you update the index, you need to get a new searcher.

=head1 AUTHORS

Jason McIntosh
Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

