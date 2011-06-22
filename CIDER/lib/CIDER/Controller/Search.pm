package CIDER::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 search

=cut

sub search :Path :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    # $form is the full search form.
    my $form = $c->stash->{ form };
    if ( $form->submitted_and_valid ) {
        # Perform the search.
        my $field = $form->param_value( 'field' );
        my $query = $form->param_value( 'query' );
        my $query_str = $query;

        if ( $field ne 'all' ) {
            $query_str = "$field:($query)";

            $query = KinoSearch::Search::TermQuery->new(
                field => $field,

                # NOTE: search is case-insensitive, but only because
                # the terms in the index have been downcased, so we
                # must downcase the query term.  (QueryParser does
                # this automatically, but the TermQuery constructor
                # does not.)
                term => lc $query,
            );
        }

        my $hits = $c->model( 'Search' )->search(
            query => $query,
            num_wanted => 20, # TO DO: parameterize this?
        );

        my @objects;
        while ( my $hit = $hits->next  ) {
            my $object = $c->model( 'CIDERDB::Object' )->find( $hit->{id} );
            if ( $object ) {
                push @objects, $object;
            }
            else {
                $c->log->error( "Search hits included nonexistent object with"
                                    . " ID '$hit->{id}'." );
            }
        }
        $c->stash->{ objects } = \@objects;
        $c->stash->{ query } = $query_str;
        $c->stash->{ template } = 'search/results.tt';
    }
}

=head2 make_index

Private action to (re)make the search index from scratch, optimized.
It's run automatically by L<Catalyst::Plugin::Scheduler>.  See
C<$APP_HOME/scheduler.yml>.

=cut

sub make_index :Private {
    my ( $self, $c ) = @_;

    $c->model( 'CIDERDB' )->schema->indexer->make_index;
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
