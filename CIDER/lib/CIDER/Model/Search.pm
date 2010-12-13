package CIDER::Model::Search;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

# The args to pass to the searcher constuctor -- most crucially the path to
# the index directory -- are located in the app config file.
# Here are some reasonable defaults, though:
__PACKAGE__->config(
    class => 'KinoSearch::Search::IndexSearcher',
    args  => {
        index => '/tmp/cider_index',
    },
);

__PACKAGE__->meta->make_immutable;

# IndexSearcher wants a plain list, not a hashref, so we have to do this...
sub mangle_arguments {
    my ( $self, $args ) = @_;
    return %$args;
}

1;

=head1 NAME

CIDER::Model::Search - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

