package CIDER::Model::Import;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

use CIDER::Logic::Importer;

has 'rngschema_file' => (
    is => 'rw',
    isa => 'Str',
);

has schema => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    my ( $c ) = @_;

    my $schema = $c->model( 'CIDERDB' )->schema;

    return $self->meta->clone_object(
        $self,
        schema => $schema,
        rngschema_file => $c->config->{ home } . '/schema/cider-import.rng',
    );
}

sub importer {
    my $self = shift;

    return CIDER::Logic::Importer->new(
        schema => $self->schema,
        rngschema_file => $self->rngschema_file,
    );
}

__PACKAGE__->meta->make_immutable;

1;
