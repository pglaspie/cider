package CIDER::Logic::Utils;

use strict;
use warnings;

use base qw( Exporter );
our @EXPORT    = qw( iso_8601_date );
our @EXPORT_OK = qw( iso_8601_date );

=head1 FUNCTIONS

=head2 iso_8601_date( $date )

Returns true iff $date is undefined, empty, or a valid ISO-8601 format
date string, i.e. YYYY, YYYY-MM, or YYYY-MM-DD, with month in 1..12
and date in 1..31.

=cut

sub iso_8601_date {
    my ( $date ) = @_;

    return !defined( $date ) || $date eq ''
        || $date =~ /^\d{4}(?:-(\d{2})(?:-(\d{2}))?)?$/
        && ( !defined( $1 )
             || ( $1 >= 1 && $1 <= 12
                  && ( !defined( $2 )
                       || ( $2 >= 1 && $2 <= 31 ) ) ) );
}

1;
