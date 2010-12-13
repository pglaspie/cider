package CIDER::Controller::List;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

CIDER::Controller::List - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @objects = $c->model( 'CIDERDB' )
                    ->resultset( 'Object' )
                    ->root_objects;
    
    $c->stash->{ objects } = \@objects;

    if ( my $held_object_id = $c->session->{ held_object_id } ) {
        my $held_object = $c->model( 'CIDERDB::Object' )
                            ->find( $held_object_id );
        $c->stash->{ held_object } = $held_object;
    }

    $c->stash->{ template } = 'object_list.tt';
}

sub children :Args(1) :Path('children') {
    my ( $self, $c, $parent_id ) = @_;

    my $parent = $c->model( 'CIDERDB' )
                   ->resultset( 'Object' )
                   ->find( $parent_id );

    my @children = $parent->children;

    # This is called as AJAX, so let's suppress the wrapper.
    $c->stash->{ current_view } = 'NoWrapperTT';
        
    $c->stash->{ objects } = \@children;
    $c->stash->{ template } = 'child_list.tt';
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
