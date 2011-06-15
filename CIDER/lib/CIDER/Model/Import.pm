package CIDER::Model::Import;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

use CIDER;

__PACKAGE__->config(
    class => 'CIDER::Logic::Importer',
    args  => CIDER->config->{ 'Model::CIDERDB' },
);

sub mangle_arguments {
    my $self = shift;
    my ( $args ) = @_;

    return $args->{ connect_info };
}

__PACKAGE__->meta->make_immutable;

1;
