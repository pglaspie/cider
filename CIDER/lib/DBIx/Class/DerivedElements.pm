package DBIx::Class::DerivedElements;

use strict;
use warnings;

use base 'DBIx::Class';

=head accession_numbers

Returns a semicolon-delimited string of the accession_number field of
all descendant Item objects.

=cut

sub accession_numbers {
    my $self = shift;

    return join ';', grep { $_ } map { $_->can( 'accession_numbers' )
                                       ? $_->accession_numbers
                                       : $_->accession_number } $self->children;
}

1;
