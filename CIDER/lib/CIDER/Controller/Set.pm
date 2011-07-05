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

    # Store a list of export template files in the stash. These'll help
    # build an export form.
    my $template_directory = $c->config->{ export }->{ template_directory };
    my @template_files;
    my $dh;
    opendir $dh, $template_directory;
    if ( $dh ) {
        while ( my $template_file = readdir $dh ) {
            next if $template_file =~ /^\./; # Exclude dotfiles.
            push @template_files, $template_file;
        }
        closedir $dh;
    }
    else {
        $c->log->error( "Failed to opendir export config directory "
                        . "'$template_directory': $!" );
    }
    $c->stash->{ template_files } = \@template_files;
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
    
    $c->res->redirect(
        $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
}

sub delete :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ set }->delete;
    $c->res->redirect( $c->uri_for( $self->action_for( 'list' ) ) );
}

sub batch_edit :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };
    $set->set_field( $c->req->params->{ field },
                     $c->req->params->{ new_value } );

    $c->flash->{ we_just_did_batch_edit } = 1;

    $c->res->redirect(
        $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
}

sub search_and_replace :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    my $field = $c->req->params->{ field };
    my $old   = $c->req->params->{ old_value };
    my $new   = $c->req->params->{ new_value };

    unless ( $c->req->params->{ confirm } ) {
        my $rs = $set->search_in_field( $field, $old );
        if ( $rs->count ) {
            my @replace = ();
            for my $obj ( $rs->all ) {
                my $old_value = $obj->$field;
                my $new_value = $old_value;
                $new_value =~ s/$old/$new/g;
                push @replace, {
                    obj => $obj,
                    old => $old_value,
                    new => $new_value,
                };
            }

            $c->stash->{ replace } = \@replace;
            $c->stash->{ field } = $field;
            $c->stash->{ old_value } = $old;
            $c->stash->{ new_value } = $new;
        } 
        else {
            $c->flash->{ we_just_did_search_and_replace } = 1;
            $c->flash->{ count } = 0;

            $c->res->redirect(
                $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
        }
    }
    else {
        my $count = $set->search_and_replace( {
            field => $field,
            old   => $old,
            new   => $new
        } );

        $c->flash->{ we_just_did_search_and_replace } = 1;
        $c->flash->{ count } = $count;

        $c->res->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
    }
}

sub export :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ objects } = [ $c->stash->{ set }->objects ];

    $c->forward( $c->controller( 'Object' )->action_for( '_export' ) );
}

=head1 AUTHOR

Jason McIntosh, Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
