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

        # The results page has a create-a-new-set form on it.
        my $set_creation_form = $self->form;
        $set_creation_form->
            load_config_filestem( 'set/create' );
        $c->stash->{ set_creation_form } = $set_creation_form;

        # Aim this form at the set-creation action.
        $set_creation_form->action( '/search/create_set' );
     
        # Stick the last query in the flash, for the create-set action's use.
        if ( ref $query ) {
            $c->flash->{ last_search_query } = $query->to_string;
        }
        else {
            $c->flash->{ last_search_query } = $query;
        }
    }
}

=head2 create_set

Path: /search/create_set

This action is called if the user asks to create a new set from search
results. It creates the set, and then sends the user along to the set list.

=cut

# /search/create_set: Create a new set based on the results of the last
#                     query.
sub create_set :Path('create_set') :Args(0) :FormConfig('set/create') {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    
    # Create the set object.
    my $name = $form->param( 'name' );
    my $rs = $c->model( 'CIDERDB::ObjectSet' );
    my $set = $rs->create( {
        name => $name,
        owner => $c->user->id,
    } );

    # Populate the new set with the results of the last query.
    my $query;
    if ( my $dumped_query = $c->flash->{ last_search_query } ) {
        $query = $c->flash->{ last_search_query };
    }
    else {
        $c->log->error('Went to create_set without a last_search_query '
                       . ' defined. Redirecting to to the search page.');
        $c->res->redirect( $c->uri_for( '/search' ) );
        return;
    }

    my $hits = $c->model( 'Search' )->search(
        query => $query,
    );

    while ( my $hit = $hits->next ) {
        my $object = $c->model( 'CIDERDB::Object' )->find( $hit->{id} );
        $set->add ( $object );
    }

    # That done, redirect the user to the set list.
    $c->flash->{ set_created_from_search } = $name;
    $c->res->redirect( $c->uri_for( '/set/list' ) );
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
