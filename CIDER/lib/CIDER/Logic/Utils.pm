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

1;
