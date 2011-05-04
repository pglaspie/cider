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
        $c->model( 'CIDERDB' )->schema->user( $c->user->id );
    }
    return 1; # success; carry on to next action
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
