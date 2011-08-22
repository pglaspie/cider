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

1;
