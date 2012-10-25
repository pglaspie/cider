package CIDER::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

CIDER::Controller::Root - Root Controller for CIDER

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->user ) {
        $c->response->redirect(
            $c->uri_for( $c->controller( 'List' )->action_for( 'index' ),
                     )
        );
    }
    else {
        $c->response->redirect(
            $c->uri_for( $c->controller( 'Auth' )->action_for( 'login' ),
                     )
        );
    }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

# called for all actions, from the top-most controller downwards
sub auto : Private {
    my ( $self, $c ) = @_;
    if ( !$c->user_exists ) {
        my $login_action = $c->controller( 'Auth' )->action_for( 'login' );
        if ( $c->action ne $login_action ) {
            $c->res->redirect( $c->uri_for( $login_action ) );
            return 0; # abort request and go immediately to end()
        }
    } else {
        $c->model( 'CIDERDB' )->schema->user( $c->user );
    }
    return 1; # success; carry on to next action
}

=head1 AUTHORS

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
