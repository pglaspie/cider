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
    my %params = @_;

    my $searcher = Lucy::Search::IndexSearcher->new(
        index => $self->schema->search_index,
    );

    unless ( ref $params{ query } ) {
        my $qp = Lucy::Search::QueryParser->new(
            schema => $searcher->get_schema,
        );
        $qp->set_heed_colons( 1 );

		# Transform a request for all-caps 'NULL' into sentinel value 'CIDERNULL',
		# as defined by the indexer.
		$params{ query } =~ s/(\w+)\s*:\s*NULL/$1:CIDERNULL/g;

        $params{ query } = $qp->parse( $params{ query } );
    }

    return $searcher->hits( %params );
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

Search the index, using L<Lucy::Search::IndexSearcher>.  The
params can be any of the following:

=over

=item *

B<query> - Either a L<Lucy::Search::Query> object or a query
string.  If a query string, it will be parsed with set_heed_colons
true.  See L<Lucy::Search::QueryParser>.

=item *

B<offset> - The number of most-relevant hits to discard, typically
used when "paging" through hits N at a time. Setting C<offset> to 20
and C<num_wanted> to 10 retrieves hits 21-30, assuming that 30 hits
can be found.

=item *

B<num_wanted> - The number of hits you would like to see after
C<offset> is taken into account.

=item *

B<sort_spec> - A L<Lucy::Search::SortSpec>, which will affect
how results are ranked and returned.

=back

Returns an instance of L<Lucy::Search::Hits>.

=head1 AUTHORS

Jason McIntosh
Doug Orleans

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

