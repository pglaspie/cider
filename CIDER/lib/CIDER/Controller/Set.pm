package CIDER::Controller::Set;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

use CIDER::Form::BatchEdit;

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

    $c->forward( $c->controller( 'Object' )
                     ->action_for( '_setup_export_templates' ) );
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

sub delete_recursively :Chained('set') :Args(0) {
	my ( $self, $c ) = @_;
	
	my $set = $c->stash->{ set };
	
	# Carry this action out only if the "I'm sure" checkbox is checked.
	if ( $c->req->params->{ confirm_recursive_delete } ) {
		for my $object ( $set->objects ) {
			$object->delete;
		}
		$c->forward( $self->action_for( 'delete' ) );
	}
	else {
		$c->flash->{ there_was_a_recursive_deletion_failure } = 1;
	    $c->res->redirect( $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
	}
}

sub export :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ objects } = [ $c->stash->{ set }->contents ];

    $c->forward( $c->controller( 'Object' )->action_for( '_export' ) );
}

#######################
# Batch-edit methods
#######################

# There's the one batch_edit endpoint, and then a bunch of `batch_edit_*` private
# actions that it has the authority to call in turn. Each of the latter has dominion
# over one batch-editable field. (Which is to say, over one possible value in the
# "field" <select> menu on the batch-edit form.)

sub batch_edit :Chained('set') :Args(0) {
    my ( $self, $c ) = @_;

    my $form = CIDER::Form::BatchEdit->new( schema => $c->model( 'CIDERDB' )->schema );
    $c->stash->{ form } = $form;
    my $set = $c->stash->{ set };

    if ( $form->process(
        params => $c->req->parameters,
        schema => $c->model( 'CIDERDB' )->schema,
       ) ) {
        # The form is valid. Let's act on it.
        my $private_action = 'batch_edit_' . $form->field( 'field' )->value;
        $c->forward( $private_action );
        $c->flash->{ batch_edit_successful } = 1;
	    $c->res->redirect( $c->uri_for( $self->action_for( 'detail' ), [$set->id] ) );
    }

}

sub batch_edit_title :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    if ( $c->stash->{ form }->field( 'title_kind' )->value eq 'replace' ) {
        for my $object ( $set->objects ) {
            $object->title( $c->stash->{ form }->field( 'title_new_title' )->value );
            $object->update;
        }
    }
    else {
        for my $object( $set->objects ) {
            my $title = $object->title;
            my $from_substring = $c->stash->{ form }
                                   ->field( 'title_incorrect_text' )
                                   ->value;
            my $to_substring = $c->stash->{ form }
                                 ->field( 'title_corrected_text' )
                                 ->value;
            $title =~ s/$from_substring/$to_substring/gie;
            $object->title( $title );
            $object->update;
        }
    }
}

sub batch_edit_description :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    if ( $c->stash->{ form }->field( 'description_kind' )->value eq 'replace' ) {
        for my $object ( $set->objects ) {
            my $item = $object->item or next;
            $item->description( $c->stash->{ form }
                                    ->field( 'description_new_description' )
                                    ->value
                                );
            $item->update;
        }
    }
    else {
        for my $object( $set->objects ) {
            my $item = $object->item or next;
            my $description = $item->description;
            my $from_substring = $c->stash->{ form }
                                   ->field( 'description_incorrect_text' )
                                   ->value;
            my $to_substring = $c->stash->{ form }
                                 ->field( 'description_corrected_text' )
                                 ->value;
            $description =~ s/$from_substring/$to_substring/gie;
            $item->description( $description );
            $item->update;
        }
    }
}

sub batch_edit_accession :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    if ( $c->stash->{ form }->field( 'accession_kind' )->value eq 'new' ) {
        for my $object ( $set->objects ) {
            my $item = $object->item or next;
            my $accession_numbers = $item->accession_number;
            if ( defined( $accession_numbers) && $accession_numbers =~ /\S/ ) {
                $accession_numbers = "$accession_numbers, ";
            }
            else {
                $accession_numbers = '';
            }
            $item->accession_number( $accession_numbers
                                       . $c->stash->{ form }
                                        ->field( 'accession_new_number' )
                                        ->value
                                     );
            $item->update;
        }
    }
    else {
        for my $object( $set->objects ) {
            my $item = $object->item or next;
            my $accession_numbers = $item->accession_number;
            my $from_substring = $c->stash->{ form }
                                   ->field( 'accession_incorrect_number' )
                                   ->value;
            my $to_substring = $c->stash->{ form }
                                 ->field( 'accession_corrected_number' )
                                 ->value;
            $accession_numbers =~ s/$from_substring/$to_substring/gie;
            $item->accession_number( $accession_numbers );
            $item->update;
        }
    }
}

sub batch_edit_restriction :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    for my $object ( $set->objects ) {
        my $item = $object->item or next;
        $item->restrictions( $c->stash->{ form }->field( 'restriction' )->value );
        $item->update;
    }

}

sub batch_edit_creator :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    for my $object ( $set->objects ) {
        my $item = $object->item or next;
        $item->add_to_creators(
            {
                id => $c->stash->{ form }->field( 'creator_name' )->value,
            }
        );
    }

}

sub batch_edit_dc_type :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    for my $object ( $set->objects ) {
        my $item = $object->item or next;
        $item->dc_type( $c->stash->{ form }->field( 'dc_type' )->value );
        $item->update;
    }

}

sub batch_edit_rights :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    my $class_type = $c->stash->{ form }->field( 'rights_class' )->value;

    for my $object ( $set->objects ) {
        my $item = $object->item or next;
        for my $class ( $item->$class_type ) {
            $class->rights( $c->stash->{ form }->field( 'rights' )->value );
            $class->update;
        }
    }

}

sub batch_edit_format :Private {
    my ( $self, $c ) = @_;

    my $set = $c->stash->{ set };

    my $class_type = $c->stash->{ form }->field( 'format_class' )->value;

    for my $object ( $set->objects ) {
        my $item = $object->item or next;
        for my $class ( $item->$class_type ) {
            $class->format( $c->stash->{ form }->field( 'format' )->value );
            $class->update;
        }
    }
}

=head1 AUTHOR

Jason McIntosh, Doug Orleans

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

__PACKAGE__->meta->make_immutable;

1;
