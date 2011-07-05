package CIDER::View::NoWrapperTT;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    CATALYST_VAR => 'c',
    render_die => 1,
    FILTERS => {
        csv => \&csv,
    },
    ABSOLUTE => 1,
);

sub csv {
    my ( $value ) = @_;

    if ( $value =~ /[,"]/ ) {
        $value =~ s/"/""/g;
        $value = "\"$value\"";
    }

    return $value;
}


=head1 NAME

CIDER::View::NoWrapperTT - TT View for CIDER

=head1 DESCRIPTION

TT View for CIDER.

=head1 FILTERS

The following filters are available to templates using this view:

=head2 [% value | csv %]

Quotes the value for CSV if needed, i.e. if it contains a comma or a
double-quote.

=head1 SEE ALSO

L<CIDER>

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
