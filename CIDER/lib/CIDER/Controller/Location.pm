package CIDER::Controller::Location;
use Moose;
use namespace::autoclean;
use Locale::Language;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Location - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for Location CRUD.

=head1 METHODS

=cut


=head2 location

=cut

sub location :Chained('/') :CaptureArgs(1) {
    my ( $self, $c, $barcode ) = @_;
    
    my $loc = $c->model( 'CIDERDB' )->resultset( 'Location' )->find( $barcode );
    
    $c->stash->{ barcode } = $barcode;
    $c->stash->{ location } = $loc;
}

sub detail :Chained('location') :PathPart('') :Args(0) :FormConfig('location') {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };

    my $loc = $c->stash->{ location };

    unless ( defined( $loc ) ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $form->get_field( 'submit' )->value( 'Update location' );

    if ( $form->submitted_and_valid ) {
        $form->model->update( $loc );
        $c->response->redirect( $c->req->uri );
    }
    elsif ( not $form->submitted ) {
        $form->model->default_values( $loc );
    }
}

sub create :Chained('location') :Args(0) :FormConfig('location') {
    my ( $self, $c ) = @_;

    my $barcode = $c->stash->{barcode};

    unless ( defined( $barcode ) ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    if ( $c->stash->{location} ) {
        # A location with that barcode already exists; redirect to its
        # detail page.
        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $barcode ] ) );
        $c->detach;
    }

    my $form = $c->stash->{ form };

    $form->get_field( 'submit' )->value( 'Create location' );

    if ( not $form->submitted ) {
        if ( my $return_uri = $c->flash->{ return_uri } ) {
            # We just created a new item or updated an existing item
            # with a new location barcode.
            $form->default_values( { return_uri => $return_uri } );
        }
    }
    elsif ( $form->submitted_and_valid ) {
        $form->add_valid( barcode => $barcode );

        my $loc = $form->model->create;

        if ( my $return_uri = $form->param_value( 'return_uri' ) ) {
            $c->res->redirect( $return_uri );
            return;
        }

        $c->flash->{ we_just_created_this } = 1;
        
        $c->res->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $barcode ] ) );
    }
}

=head1 AUTHOR

Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
