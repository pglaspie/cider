package CIDER::Controller::Object;
use Moose;
use namespace::autoclean;
use Locale::Language;
use File::Spec;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Object - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub object :Chained('/') :CaptureArgs(1) {
    my ( $self, $c, $object_id ) = @_;

    if ( my $object = $c->model( 'CIDERDB::Object' )->find( $object_id ) ) {
        $c->stash->{ object } = $object->type_object;
    }

    $c->forward( 'set_up_held_object' );
}

sub set_up_held_object :Private {
    my ( $self, $c ) = @_;
    if ( my $held_object_id = $c->session->{ held_object_id } ) {
        my $held_object = $c->model( 'CIDERDB::Object' )
            ->find( $held_object_id );
        $c->stash->{ held_object } = $held_object->type_object;
    }
}

sub detail :Chained('object') :PathPart('') :Args(0) :Form {
    my ( $self, $c ) = @_;

    my $object = $c->stash->{ object };
    unless ( defined( $object ) ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->forward( '_setup_export_templates' );

    my $form = $self->form;
    my $type = $object->type;
    $form->load_config_filestem( "object/$type" );

    $self->_build_language_field( $c, $form );

    $form->get_field( 'submit' )->value( "Update \u$type" );

    $form->process;

    $c->stash->{ form } = $form;

    if ( not $form->submitted ) {
        $form->model->default_values( $object );
    }
    elsif ( $form->submitted_and_valid ) {
        $c->forward( '_ensure_location', [ 'update' ] );
        $form->model->update( $object );

        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [$object->id] )
        );
    }
}

sub add_to_set :Chained('object') :Args(0) {
    my ( $self, $c ) = @_;

    my $set_id = $c->request->param( 'set_id' );
    my $set = $c->model( 'CIDERDB::ObjectSet' )->find( $set_id );

    my $object = $c->stash->{ object };
    if ( $set ) {
        $object->add_to_sets( $set );
    }
    else {
        $c->log->warn( "Attempt to add object " . $object->id
                       . " to nonexistent set $set_id");
    }

    $c->response->redirect(
        $c->uri_for( $self->action_for( 'detail' ), [$object->id] )
    );
}

sub create_collection :Path('create/collection') :Args(0) :FormConfig('object/collection') {
    my ( $self, $c ) = @_;

    $c->stash->{ object_type } = 'collection';
    $c->forward('_create');
}

sub create_series :Path('create/series') :Args(0) :FormConfig('object/series') {
    my ( $self, $c ) = @_;

    $c->stash->{ object_type } = 'series';
    $c->forward('_create');
}

sub create_item :Path('create/item') :Args(0) :FormConfig('object/item') {
    my ( $self, $c ) = @_;

    $c->stash->{ object_type } = 'item';
    $c->forward('_create');
}

sub create :Path('create') :Args(0) {
    my ( $self, $c ) = @_;

    my $type = $c->request->param( 'type' );
    my $parent_id = $c->request->param( 'parent_id' );
    if ( my $action = $self->action_for( "create_$type" ) ) {
        $c->flash->{ parent_id } = $parent_id;
        $c->response->redirect( $c->uri_for( $action ) );
    }
    else {
        $c->log->warn( "Invalid request to create object of type '$type'" );
        $c->response->redirect(
            $c->uri_for( $c->controller( 'List' )->action_for( 'index' ) )
        );
    }
}

sub _create :Private {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'object/create.tt';

    my $form = $c->stash->{ form };
    my $type = $c->stash->{ object_type };

    $self->_build_language_field( $c, $form );

    $form->get_field( 'submit' )->value( "Create \u$type" );

    if ( not $form->submitted ) {
        my $parent_id = $c->stash->{ parent_id };

        if ( $parent_id ) {
            $form->default_values( { parent_id => $parent_id } );
        }

        $form->default_values( { language => 'eng' } );
    }
    elsif ( $form->submitted_and_valid ) {
        $c->forward( '_ensure_location', [ 'create' ] );

        my $object = $form->model->create( );

        $c->flash->{ we_just_created_this } = 1;

        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [$object->id] )
        );
    }
}

sub _ensure_location :Private {
    my ( $self, $c, $action ) = @_;

    my $form = $c->stash->{ form };

    my $barcode = $form->param_value( 'location' );
    return unless $barcode &&
        !$c->model( 'CIDERDB::Location' )->find( $barcode );

    # No location exists with the given barcode: give the user a form
    # to create one, then come back here afterward.

    $c->flash->{ return_uri } =
        $c->uri_for( $c->action, $c->req->captures,
                     { map { $_ => $form->param_value( $_ ) } $form->valid } );
    $c->flash->{ title } = $form->param_value( 'title' );
    $c->flash->{ action } = $action;

    $c->res->redirect(
        $c->uri_for( $c->controller( 'Location' )->action_for( 'create' ),
                     [ $barcode ] ) );
    $c->detach;
}

sub delete :Chained('object') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ object }->delete;
    $c->response->redirect(
        $c->uri_for( $c->controller( 'List' )->action_for( 'index' ) )
    );
}

sub pick_up :Chained('object') :Args(0) {
    my ( $self, $c ) = @_;

    $c->session->{ held_object_id } = $c->stash->{ object }->id;
    $c->flash->{ we_just_picked_this_up } = 1;

    $c->response->redirect(
        $c->uri_for( $self->action_for( 'detail' ),
                     [$c->stash->{ object }->id],
                 )
    );
}

sub drop_held_object_here :Chained('object') :Args(0) {
    my ( $self, $c ) = @_;

    my $new_child = $c->stash->{ held_object };
    if ( $c->stash->{ object } ) {
        $new_child->parent( $c->stash->{ object }->id );
    }
    else {
        $new_child->parent( undef );
    }
    $new_child->update;

    delete $c->session->{ held_object_id };

    if ( $c->stash->{ object } ) {
        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ),
                         [$c->stash->{ object }->id],
                     )
        );
    }
    else {
        $c->response->redirect(
            $c->uri_for( $c->controller( 'List' )->action_for( 'index' ) )
        );
    }
}

sub _build_language_field {
    my ( $self, $c, $form ) = @_;

    my $field = $form->get_field( 'language' );

    if ( $field ) {
        my @options = map {
            [ language2code( $_, LOCALE_LANG_ALPHA_3 ), $_ ]
        } all_language_names;

        $field->options( \@options );
    }
}

sub export :Chained( 'object' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    $c->stash->{ objects } = [ $c->stash->{ object } ];

    $c->forward( $self->action_for( '_export' ) );
}

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

    my $objects = $c->stash->{ objects };

    if ( $c->req->params->{ descendants } ) {
        $objects = [ map { $_->descendants } @$objects ];
        $c->stash->{ objects } = $objects;
    }

    # Update the audit trails.
    $_->export for @$objects;

    $c->stash->{ current_view } = 'NoWrapperTT';
}

sub _setup_export_templates :Private {
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


=head1 AUTHOR

Jason McIntosh, Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
