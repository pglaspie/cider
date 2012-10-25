package CIDER::Logic::Extent;

use Moose;

has volume => (
    is => 'ro',
    isa => 'Num',
);

has types => (
    is => 'ro',
    isa => 'ArrayRef[CIDER::Schema::Result::UnitType]',
);

has counts => (
    is => 'ro',
    isa => 'HashRef[Int]',
);

=head2 count( type )

Returns the number of locations of the given unit type in this extent.

=cut

sub count {
    my $self = shift;
    my ( $type ) = @_;

    return $self->counts->{ $type };
}

use overload '""' => sub {
    my $self = shift;

    my @strs = ();

    my $volume = $self->volume;
    push @strs, "$volume cubic ft." if $volume;

    for my $type ( @{ $self->types } ) {
        if ( my $count = $self->count( $type ) ) {
            my $str = "$count \l$type";
            if ( $count == 1
                 || $type eq 'Digital objects'
                 || $type eq 'Audio-visual media' ) {
                push @strs, $str;
            }
            else {
                push @strs, "${str}s";
            }
        }
    }


    return join ', ', @strs;
},
    fallback => 1;

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
