package DBIx::Class::DerivedElements;

use strict;
use warnings;

use base 'DBIx::Class';
use List::Util qw(minstr maxstr sum);
use CIDER::Logic::Extent;

=head date_from

Returns the earliest date_from of all descendant Item objects.

=cut

sub date_from {
    my $self = shift;

    # Fortunately, ISO-8601 dates can be compared with string-compare,
    # so we can just use minstr/maxstr.
    return minstr grep { defined } map { $_->date_from }
        $self->children;
}

=head date_to

Returns the latest date_to of all descendant Item objects.

=cut

sub date_to {
    my $self = shift;

    return maxstr grep { defined } map { $_->date_to || $_->date_from }
        $self->children;
}

=head2 _uniq_objs

Returns a list with duplicate objects (same id) removed.

=cut

sub _uniq_objs {
    my %locs = map { $_->id => $_ } @_;
    return values %locs;
}

=head extent

Returns a CIDER::Logic::Extent object containing the computed extent
of the items.

=cut

sub extent {
    my $self = shift;

    my @items = $self->item_descendants;

    # Count each item location only once per item (i.e. if an item has
    # the same location via multiple classes).
    my @locations = map { _uniq_objs $_->locations } @items;

    my @unique_locations = _uniq_objs @locations;
    # The volume is the sum of all location volumes, counting each
    # location once even if there are multiple items in that location.
    # (Non-box locations have volume = undef, so those are ignored.)
    my $volume = sum 0, grep { defined } map { $_->volume } @unique_locations;

    my @types = $self->result_source->schema->resultset( 'UnitType' )->search(
        # Only count unit types without volume.
        { volume => undef },
        { order_by => 'id' },
    );
    my %counts = map {
        my $type = $_;
        my $count = grep { $_->unit_type->id == $type->id }
            # Digital object locations are counted multiple times even
            # for the same location.
            ( $type eq 'Digital objects' ? @locations : @unique_locations );
        $type => $count || 0
    } @types;

    return CIDER::Logic::Extent->new( {
        volume => $volume,
        types => \@types,
        counts => \%counts,
    } );
}

=head restrictions

Returns 'none', 'some', or 'all', depending on whether the descendant
Items have restrictions or not.

=cut

sub restrictions {
    my $self = shift;

    my @items = $self->item_descendants;
    my @restricted = grep { $_->restrictions ne 'none' } @items;
    return 'none' if @restricted == 0;
    return 'all' if @restricted == @items;
    return 'some';
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
