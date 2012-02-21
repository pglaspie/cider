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

# TO DO: get this info from the classes? or YAML?

my $lists = {
    application => {
        name => 'Application',
        class => 'Application',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        } ],
        order_by => 'me.name',
        join => 'digital_objects',
        sublist_field => 'function',
        sublists => {
            checksum => 'Checksum',
            media_image => 'Media Image',
            virus_check => 'Virus Check',
        },
    },
    file_extension => {
        name => 'File Extension',
        class => 'FileExtension',
        fields => [ {
            name => 'extension',
            label => 'Extension',
            constraint => 'Required',
        } ],
        order_by => 'me.extension',
        join => 'digital_objects',
    },
    format => {
        name => 'Format',
        class => 'Format',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        } ],
        order_by => 'me.name',
        sublist_field => 'class',
        sublists => {
            container => 'Container',
            bound_volume => 'Bound Volume',
            three_dimensional_object => '3 Dimensional Object',
            audio_visual_media => 'Audio-Visual Media',
            document => 'Document',
            physical_image => 'Physical Image',
            digital_object => 'Digital Object',
            browsing_object => 'Browsing Object',
        },
    },
    function => {
        name => 'Function',
        class => 'Function',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        } ],
        order_by => 'me.name',
        join => 'record_contexts',
    },
    geographic_term => {
        name => 'Geographic Term',
        class => 'GeographicTerm',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        }, {
            name => 'note',
            label => 'Note',
        } ],
        order_by => 'me.name',
        join => 'item_geographic_terms',
    },
    name => {
        name => 'Name',
        class => 'AuthorityName',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        }, {
            name => 'note',
            label => 'Note',
        } ],
        order_by => 'me.name',
        join => 'item_authority_names',
    },
    staff => {
        name => 'Staff',
        class => 'Staff',
        fields => [ {
            name => 'first_name',
            label => 'First Name',
            constraint => 'Required',
        }, {
            name => 'last_name',
            label => 'Last Name',
            constraint => 'Required',
        } ],
        order_by => [ 'me.last_name', 'me.first_name' ],
        join => 'digital_objects',
    },
    topic_term => {
        name => 'Topic Term',
        class => 'TopicTerm',
        fields => [ {
            name => 'name',
            label => 'Name',
            constraint => 'Required',
        }, {
            name => 'note',
            label => 'Note',
        } ],
        order_by => 'me.name',
        join => 'item_topic_terms',
    },
};

=head2 index

Display links to the various authority list pages.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ lists } = $lists;
}

=head2 authority

Chain root action that gets an authority list resultset by id.

=cut

sub authority :Chained :CaptureArgs(1) {
    my ( $self, $c, $full_list_id ) = @_;

    my ( $list_id, $sublist ) = split /-/, $full_list_id;

    my $list = $lists->{ $list_id };

    if ( !$list || $list->{ sublist_field } && !$sublist ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->stash->{ list_id } = $full_list_id;
    $c->stash->{ sublist } = $sublist;
    $c->stash->{ list } = $list;

    my $name = $list->{ name };
    if ( $sublist ) {
        my $sublist_name = $list->{ sublists }->{ $sublist };
        $name = "$sublist_name $name";
    }
    $c->stash->{ name } = $name;

    my $list_class = $list->{ class };
    my $rs = $c->model( "CIDERDB::$list_class" );
    if ( $sublist ) {
        $rs = $rs->search( { $list->{ sublist_field } => $sublist } );
    }

    my $order_by = $list->{ order_by };
    my $join = $list->{ join };
    $c->stash->{ terms } = $rs->search( undef, {
        order_by => $order_by,
        #
        # The three lines below were an attempt at adding a
        # 'num_items' column so that it could omit the Delete link if
        # there are >0 items with this authority term.
        #
        # join => $join,
        # group_by => "me.id",
        # '+columns' => [ { num_items => { count => "$join.id" } } ],
        #
        # This results in an error:
        #    'cider.me.name' isn't in GROUP BY
        # because DBD::mysql turns on the SQL option ONLY_FULL_GROUP_BY,
        # which requires that all non-aggregate selected columns be
        # mentioned in the group_by.  I think this option can be
        # turned off for this query, but I'm not sure how;
        # alternately, we can add all the columns in the authority
        # list table to the group_by, but it seems lame to have to do that.
        #
    } );
}

=head2 form

Return a hashref of form data to populate the form with.

=cut

sub form {
    my ( $self, $c ) = @_;

    my $list = $c->stash->{ list };

    my @elements = @{ $list->{ fields } };
    if ( my $sublist = $c->stash->{ sublist } ) {
        push @elements, {
            type => 'Hidden',
            name => $list->{ sublist_field },
            value => $c->stash->{ sublist },
        };
    }
    push @elements, { type => 'Submit', name => 'submit' };

    return {
        elements => \@elements,
        model_config => { resultset => $list->{ class } },
    };
}

=head2 browse

Browse the authority names in an authority list.

=cut

sub browse :Chained( 'authority' ) :PathPart('') :Args(0) :FormMethod( 'form' )
{
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');

    $form->get_field( 'submit' )->value( 'Add a new ' . $c->stash->{ name } );
}

=head2 browse_FORM_VALID

Add a new authority term from a valid submitted form.

=cut

sub browse_FORM_VALID {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };

    my $term = $form->model->create;

    # TO DO: show error message if $term is undef

    $c->flash->{ added } = 1;
    $c->flash->{ term } = $term;
    $c->res->redirect( $c->req->uri );
}

=head2 get

Chain action that gets an authority term by id.

=cut

sub get :Chained( 'authority' ) :PathPart('') :CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $term = $c->stash->{ terms }->find( $id );

    unless ( $term ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->stash->{ term } = $term;
}

=head2 edit

Edit an authority term.

=cut

sub edit :Chained( 'get' ) :Args(0) :FormMethod( 'form' ) {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };

    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');

    $form->get_field( 'submit' )->value( 'Update ' . $c->stash->{ name } );
}

=head2 edit_FORM_NOT_SUBMITTED

Show a form to edit an authority term.

=cut

sub edit_FORM_NOT_SUBMITTED {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    my $term = $c->stash->{ term };

    $form->model->default_values( $term );
}

=head2 edit_FORM_VALID

Update an authority term from a valid submitted form.

=cut

sub edit_FORM_VALID {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    my $term = $c->stash->{ term };

    $form->model->update( $term );

    $c->flash->{ updated } = 1;
    $c->flash->{ term } = $term;
    $c->res->redirect( $c->uri_for( $self->action_for( 'browse' ),
                                    [ $c->stash->{ list_id } ] ) );
}

=head2 delete

Delete an authority term.

=cut

sub delete :Chained( 'get' ) :Args(0) {
    my ( $self, $c ) = @_;

    my $term = $c->stash->{ term };
    $c->flash->{ term } = "$term";
    $term->delete;

    $c->flash->{ deleted } = 1;
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
