package CIDER::Controller::Set;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Set - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub set :Chained('/') :CaptureArgs(1) {
    my ( $self, $c, $set_id ) = @_;

    my $set = $c->model( 'CIDERDB' )
                ->resultset( 'ObjectSet' )
                ->find( $set_id );

    $c->stash->{ set } = $set;
}
         
sub detail :Chained('set') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

}

sub list :Path('list') :Args(0) :FormConfig('set/create') {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };

    if ( $form->submitted_and_valid ) {
        my $name = $form->param( 'name' );
        my $rs = $c->model( 'CIDERDB::ObjectSet' );

        $rs->create( {
            name => $name,
            owner => $c->user->id,
        } );
    }
}

sub remove_object :Args(1) :Chained('set') {
    my ( $self, $c, $object_id ) = @_;

    my $set = $c->stash->{ set };
    my ( $link ) = $c->model( 'CIDERDB' )
                     ->resultset( 'ObjectSetObject' )
                     ->search(
                         {
                             object => $object_id,
                             object_set => $set->id,
                         }
                     );
    if ( $link ) {
        $link->delete;
    }
    else {
        $c->log->warn( "Request to remove object $object_id from set "
                       . $set->id
                       . ", but it wasn't there." );
    }
    
    $c->response->redirect(
        $c->uri_for( $c->controller( 'Set' )->action_for( 'detail' ),
                     [$set->id],
                 )
    );
}

sub delete :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ set }->delete;
    $c->response->redirect(
        $c->uri_for( $c->controller( 'Set' )->action_for( 'list' ) )
    );
}

=head1 AUTHOR

Jason McIntosh, Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
