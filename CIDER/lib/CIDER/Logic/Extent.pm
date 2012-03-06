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
    push @strs, "$volume cubic feet" if $volume;

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

    if ( @strs > 1 ) {
        my $last = pop @strs;
        push @strs, "and $last";
    }

    return join ', ', @strs;
},
    fallback => 1;

1;
