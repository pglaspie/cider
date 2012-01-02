package CIDER::Controller::RecordContext;
use Moose;
use namespace::autoclean;
use File::Spec;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::RecordContext - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for editing record contexts.

=head1 ACTIONS

=cut

=head2 index

Display a list of record contexts with links to their detail pages.

=cut

sub index :Path( '' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    my $model = $c->model( 'CIDERDB::RecordContext' );
    my @rcs = $model->search( undef, { order_by => 'record_id' } );
    $c->stash->{ rcs } = \@rcs;
}

=head2 create

Create a new record context.  If successful, redirect to its detail page.

=cut

sub create :Local :Args( 0 ) :FormConfig( 'recordcontext' ) {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    $form->get_field( 'submit' )->value( 'Create' );

    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');


    if ( $form->submitted_and_valid ) {
        my $rc = $form->model->create;

        $c->flash->{ we_just_created_this } = 1;

        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $rc->record_id ] )
        );
    }
}

=head2 recordcontext

Chained action to retrieve a record context by its record_id.  The
RecordContext object (if any) is stored in $c->stash->{ rc }.

=cut

sub recordcontext :Chained( '/' ) :CaptureArgs( 1 ) {
    my ( $self, $c, $record_id ) = @_;

    my $model = $c->model( 'CIDERDB::RecordContext' );
    if ( my $rc = $model->find( { record_id => $record_id } ) ) {
        $c->stash->{ rc } = $rc;
    }
}

=head2 detail

Edit a record context.

=cut

sub detail :Chained( 'recordcontext' ) :PathPart( '' ) :Args( 0 )
    :FormConfig( 'recordcontext' )
{
    my ( $self, $c ) = @_;

    my $rc = $c->stash->{ rc };
    unless ( defined( $rc ) ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->forward( $c->controller( 'Object' )
                     ->action_for( '_setup_export_templates' ) );

    my $form = $c->stash->{ form };
    $form->get_field( 'submit' )->value( 'Update' );

    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');

    if ( not $form->submitted ) {
        $form->model->default_values( $rc );
    }
    elsif ( $form->submitted_and_valid ) {
        $form->model->update( $rc );

        $c->flash->{ we_just_updated_this } = 1;

        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $rc->record_id ] )
        );
    }
}

=head2 delete

Delete a record context, then redirect to the index page.

=cut

sub delete :Chained( 'recordcontext' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    $c->stash->{ rc }->delete;
    $c->response->redirect( $c->uri_for( $self->action_for( 'index' ) ) );
}


sub export :Chained( 'recordcontext' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    $c->stash->{ rcs } = [ $c->stash->{ rc } ];

    $c->forward( $self->action_for( '_export' ) );
}

# TO DO: refactor this vs. Object controller

sub _export :Private {
    my ( $self, $c ) = @_;

    my $template_directory = $c->config->{ export }->{ template_directory };

    my $template = $c->req->params->{ template };
    my ( undef, undef, $template_file ) = File::Spec->splitpath( $template );

    unless ( $template eq $template_file ) {
        $c->log->error( "Request to load template '$template', "
                        . "which is not a plain filename. " );
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $template_file = File::Spec->catfile( $template_directory,
                                          $template_file );
    unless ( -f $template_file && -r $template_file ) {
        $c->log->error( "Request to load template '$template_file', but that "
                        . "doesn't look like a template file I can read." );
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }
    $c->stash->{ template } = $template_file;

    # Update the audit trails.
    $_->export for @{ $c->stash->{ rcs } };

    $c->stash->{ current_view } = 'NoWrapperTT';
}

=head1 AUTHOR

Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
