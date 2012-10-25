package DBIx::Class::DerivedElements;

use strict;
use warnings;

use base 'DBIx::Class';
use List::Util qw(minstr maxstr sum);
use CIDER::Logic::Extent;

=head date_from

Returns the earliest date_from of all descendant Item objects.

=cut

=head date_to

Returns the latest date_to of all descendant Item objects.

=head extent

Returns a CIDER::Logic::Extent object containing the computed extent
of the items.

=cut

sub extent {
    my $self = shift;

    my $dbh = $self->result_source->schema->storage->dbh;
    my $id = $self->id;
    my $volumes_ref = $dbh->selectcol_arrayref("select volume, location from object_location, unit_type, location where unit_type.id = location.unit_type and object_location.location = location.id and object_location.object = $id and volume is not null and volume > 0 group by location, volume");
    my $volume = sum 0, @{ $volumes_ref };

    my @types = $self->result_source->schema->resultset( 'UnitType' )->search(
        # Only count unit types without volume.
        { volume => undef },
        { order_by => 'id' },
    );
    my %counts = map {
        my $type = $_;
        my $group_by;
        if ( $type eq 'Digital objects' ) {
            $group_by = 'referent_object';
        }
        else {
            $group_by = 'location';
        }
        my ( $count ) = $dbh->selectrow_array("select count(distinct $group_by) from object_location, unit_type, location where unit_type.id = location.unit_type and object_location.location = location.id and object_location.object = $id and unit_type = " . $type->id);
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

    return $self->restriction_summary || 'none';
}

=head accession_numbers

Returns a semicolon-delimited string of the accession_number field of
all descendant Item objects.

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
