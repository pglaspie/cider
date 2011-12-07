package DBIx::Class::DerivedElements;

use strict;
use warnings;

use base 'DBIx::Class';
use List::Util qw(minstr maxstr);

=head date_from

Returns the earliest date_from of all descendant Item objects.

=cut

sub date_from {
    my $self = shift;

    # Fortunately, ISO-8601 dates can be compared with string-compare,
    # so we can just use minstr/maxstr.
    return minstr map { $_->date_from } $self->children;
}

=head date_to

Returns the latest date_to of all descendant Item objects.

=cut

sub date_to {
    my $self = shift;

    return maxstr map { $_->date_to || $_->date_from } $self->children;
}


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
