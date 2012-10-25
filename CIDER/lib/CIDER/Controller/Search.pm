package CIDER::Controller::Search;
use Moose;
use namespace::autoclean;

use Readonly;

# We use $BIGNUM to store a ceiling of desired search results when not using a pager.
# Ideally, this should come from the searcher object's doc_max() method.
Readonly my $BIGNUM => 1000;

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

        $query = "$field:($query)" unless ( $field eq 'all' );

        my $hits = $c->model( 'Search' )->search(
            query => $query,
            num_wanted => $BIGNUM,
        );

        my @objects;
        while ( my $hit = $hits->next  ) {
            my $object = $c->model( 'CIDERDB::Object' )->find( $hit->{id} );
            if ( $object ) {
                push @objects, $object->type_object;
            }
            else {
                $c->log->error( "Search hits included nonexistent object with"
                                    . " ID '$hit->{id}'." );
            }
        }
        $c->stash->{ objects } = \@objects;
        $c->stash->{ query } = $query;
        $c->stash->{ template } = 'search/results.tt';

        # The results page has a create-a-new-set form on it.
        my $set_creation_form = $self->form;
        $set_creation_form->
            load_config_filestem( 'set/create' );
        $c->stash->{ set_creation_form } = $set_creation_form;

        # Aim this form at the set-creation action.
        $set_creation_form->action(
            $c->uri_for( '/search/create_set' )
        );

        # Stick the last query in the flash, for the create-set action's use.
        $c->flash->{ last_search_query } = $query;
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
    my $query = $c->flash->{ last_search_query };
    unless ( $query ) {
        $c->log->error('Went to create_set without a last_search_query '
                       . ' defined. Redirecting to the search page.');
        $c->res->redirect( $c->uri_for( '/search' ) );
        return;
    }

    # Modify the query to have $BIGNUM hits per page, because we want to pour
    # all the hits into the set.
    my $hits = $c->model( 'Search' )->search(
        query      => $query,
        num_wanted => $BIGNUM,
    );

    while ( my $hit = $hits->next ) {
        my $object = $c->model( 'CIDERDB::Object' )->find( $hit->{id} );
        $set->add( $object->type_object );
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

    $c->log->debug("***In Search. About to invoke make_index on the indexer.");
    $c->model( 'CIDERDB' )->schema->indexer->make_index;

    $c->log->debug("***Done.");
}

=head1 AUTHOR

Jason McIntosh, Doug Orleans

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

__PACKAGE__->meta->make_immutable;

1;
