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


=head2 index

=cut

sub search :Path :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    # $form is the full search form.
    my $form = $c->stash->{ form };
    if ( $form->submitted_and_valid ) {
        # Perform the search.
        my $searcher = $c->model( 'Search' );
        my $query = $form->param_value( 'query' );
        $c->log->debug('Have searcher and query.');
        my $hits = $searcher->hits (
            query => $query,
            num_wanted => 50,
        );
        $c->log->debug('Have ' . $hits->total_hits . ' hits.');

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
        $c->stash->{ query } = $query;
        $c->stash->{ template } = 'search/results.tt';
    }
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
