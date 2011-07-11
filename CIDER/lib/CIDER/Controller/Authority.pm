package CIDER::Controller::Authority;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Authority - Catalyst Controller for authority lists

=head1 DESCRIPTION

Catalyst Controller for browsing and editing authority lists.

=head1 METHODS

=cut

my $list_ids = [ qw( name geographic_term topic_term format ) ];

my $list_names = {
    name            => 'Name',
    geographic_term => 'Geographic Term',
    topic_term      => 'Topic Term',
    format          => 'Format',
};

my $class_names = {
    name            => 'AuthorityName',
    geographic_term => 'GeographicTerm',
    topic_term      => 'TopicTerm',
    format          => 'ItemFormat',
};

=head2 index

Display links to the various authority list pages.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ list_ids } = $list_ids;
    $c->stash->{ list_names } = $list_names;
}

=head2 authority

Chain root action that gets an authority list resultset by id.

=cut

sub authority :Chained :CaptureArgs(1) {
    my ( $self, $c, $list_id ) = @_;

    my $list_class = $class_names->{ $list_id }
        || $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );

    my $rs = $c->model( "CIDERDB::$list_class" );

    $c->stash->{ list_id }    = $list_id;
    $c->stash->{ list_class } = $list_class;
    $c->stash->{ list_name }  = $list_names->{ $list_id };
    $c->stash->{ list }       = $rs->search( undef, {
        order_by => 'name',
        join => 'objects',
        group_by => 'me.id',
        '+columns' => [ { num_objects => { count => 'objects.id' } } ],
    } );

    $c->stash->{ notes }      = $list_id ne 'format';
}

=head2 browse

Browse the authority names in an authority list.

=cut

sub browse :Chained( 'authority' ) :PathPart('') :Args(0)
    :FormConfig('authority/edit')
{
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    unless ( $c->stash->{ notes } ) {
        $form->remove_element( $form->get_field( 'note' ) );
    }
    $form->get_field( 'submit' )
        ->value( 'Add a new ' . $c->stash->{ list_name } );
    $form->model_config->{ resultset } = $c->stash->{ list_class };
}

=head2 browse_FORM_VALID

Add a new authority name from a valid submitted form.

=cut

sub browse_FORM_VALID {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };

    my $authority = $form->model->create;

    # TO DO: show error message if $authority is undef

    $c->flash->{ added } = 1;
    $c->flash->{ authority } = $authority;
    $c->res->redirect( $c->req->uri );
}

=head2 get

Chain action that gets an authority name by id.

=cut

sub get :Chained( 'authority' ) :PathPart('') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $authority = $c->stash->{ list }->find( $id );

    unless ( $authority ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->stash->{ authority } = $authority;
}

=head2 edit

Edit an authority name.

=cut

sub edit :Chained( 'get' ) :Args(0) :FormConfig {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    unless ( $c->stash->{ notes } ) {
        $form->remove_element( $form->get_field( 'note' ) );
    }
    $form->get_field( 'submit' )
        ->value( 'Update ' . $c->stash->{ list_name } );
    $form->model_config->{ resultset } = $c->stash->{ list_class };
}

=head2 edit_FORM_NOT_SUBMITTED

Show a form to edit an authority name.

=cut

sub edit_FORM_NOT_SUBMITTED {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    my $authority = $c->stash->{ authority };

    $form->model->default_values( $authority );
}

=head2 edit_FORM_VALID

Update an authority name from a valid submitted form.

=cut

sub edit_FORM_VALID {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    my $authority = $c->stash->{ authority };

    $form->model->update( $authority );

    $c->flash->{ updated } = 1;
    $c->flash->{ authority } = $authority;
    $c->res->redirect( $c->uri_for( $self->action_for( 'browse' ),
                                    [ $c->stash->{ list_id } ] ) );
}

=head2 delete

Delete an authority name.

=cut

sub delete :Chained( 'get' ) :Args(0) {
    my ( $self, $c ) = @_;

    my $authority = $c->stash->{ authority };
    my $name = $authority->name;
    $authority->delete;

    $c->flash->{ deleted } = 1;
    $c->flash->{ name } = $name;
    $c->res->redirect( $c->uri_for( $self->action_for( 'browse' ),
                                    [ $c->stash->{ list_id } ] ) );
}

=head1 AUTHOR

Doug Orleans,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
