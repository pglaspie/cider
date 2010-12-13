package CIDER::View::NoWrapperTT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

CIDER::View::NoWrapperTT - TT View for CIDER

=head1 DESCRIPTION

TT View for CIDER.

=head1 SEE ALSO

L<CIDER>

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
