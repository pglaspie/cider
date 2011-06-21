package CIDER::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

has schema => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    my ( $c ) = @_;

    my $schema = $c->model( 'CIDERDB' )->schema;

    return $self->meta->clone_object( $self, schema => $schema );
}

sub search {
    my $self = shift;

    my $searcher = KinoSearch::Search::IndexSearcher->new(
        index => $self->schema->search_index,
    );

    return $searcher->hits( @_ );
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CIDER::Model::Search - Catalyst Model

=head1 SYNOPSIS

 my $hits = $c->model( 'Search' )->search( query => 'Item' );
 print "Found: ", $hits->total_hits, "\n";
 while ( my $hit = $hits->next ) {
     print "$hit->{ title }\n";
 }

=head1 DESCRIPTION

Catalyst Model for searching the index.

=head1 METHODS

=head2 search( [labeled params] )

Search the index, using L<KinoSearch::Search::IndexSearcher>.  The
params can be any of the following:

=over

=item *

B<query> - Either a L<KinoSearch::Search::Query> object or a query
string.  See L<KinoSearch::Search::QueryParser>.

=item *

B<offset> - The number of most-relevant hits to discard, typically
used when "paging" through hits N at a time. Setting C<offset> to 20
and C<num_wanted> to 10 retrieves hits 21-30, assuming that 30 hits
can be found.

=item *

B<num_wanted> - The number of hits you would like to see after
C<offset> is taken into account.

=item *

B<sort_spec> - A L<KinoSearch::Search::SortSpec>, which will affect
how results are ranked and returned.

=back

Returns an instance of L<KinoSearch::Search::Hits>.

=head1 AUTHORS

Jason McIntosh
Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

