package DBIx::Class::ConvertEmptyToNull;

use strict;
use warnings;

use base 'DBIx::Class';

=head store_column( $column, $value )

Override DBIC store_column to convert empty strings to nulls.

=cut

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    $value = undef if defined( $value ) && $value eq '';

    return $self->next::method( $column, $value );
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
