package CIDER::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Factory';

__PACKAGE__->config(
    class => 'KinoSearch::Search::IndexSearcher',
);

# IndexSearcher wants a plain list, not a hashref, so we have to do this...
sub mangle_arguments {
    my ( $self, $args ) = @_;
    return %$args;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

CIDER::Model::Search - Catalyst Model

=head1 DESCRIPTION

Catalyst Model for searching the index.  $c->model( 'Search' )
actually just returns a new instance of
KinoSearch::Search::IndexSearcher.

=head1 AUTHORS

Jason McIntosh
Doug Orleans

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

