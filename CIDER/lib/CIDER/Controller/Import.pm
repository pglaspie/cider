package CIDER::Controller::Import;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Import - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for batch-importing/updating CIDER objects.

=head1 METHODS

=cut


=head2 import

Display a form to upload a file to be imported.

=cut

sub import :Path :Args(0) :FormConfig { }

=head2 import_FORM_VALID

Import an uploaded file.

=cut

sub import_FORM_VALID {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    my $file = $form->param_value( 'file' );

    my $importer = $c->model( 'Import' )->importer;
    my ( $created, $updated );
    eval { ( $created, $updated ) = $importer->import_from_xml( $file->fh ); };
    if ( $@ ) {
        $c->flash->{ error } = $@;
    } else {
        $c->flash->{ import_was_successful } = 1;
        $c->flash->{ file } = $file->filename;
        $c->flash->{ created }
            = "$created object" . ( $created == 1 ? '' : 's' );
        $c->flash->{ updated }
            = "$updated object" . ( $updated == 1 ? '' : 's' );
    }

    $c->res->redirect( $c->req->uri );
}

=head1 AUTHOR

Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
