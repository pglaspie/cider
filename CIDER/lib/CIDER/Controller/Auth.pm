package CIDER::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub login :Path('login') :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{form};

    my $username = $form->param_value( 'username' );
    my $password = $form->param_value( 'password' );

    my $auth_params = {
                username => $username,
                password => $password,
    };

    if ( $form->submitted_and_valid ) {
        if ( $c->authenticate( $auth_params) )  {
            
            # passed LDAP authentication.
            # Check to see if they are in the CIDER-user database.
            my ( $cider_user ) = $c->model( 'CIDERDB::User' )
                ->search( { username => $username } );
            if ( $cider_user ) {
                # authenticated in both places
                # send them to the front page of the application
                $c->res->redirect($c->uri_for( $c->req->params->{page} || '/' ));
            } else {
                # Tufts user but not in CIDER
                $c->logout;
                $form->force_error_message(1);
                $form->form_error_message($form->stash->{not_in_cider_message});
            }
        } else {
             # User failed LDAP authentication.
             # Display an error and let them try again.
             $form->force_error_message(1);
             $form->form_error_message($form->stash->{bad_auth_message});
        }

    }
}

sub logout :Path('logout') :Args(0) {
    my ( $self, $c ) = @_;

    $c->logout;

    $c->response->redirect($c->uri_for('/'));

}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
