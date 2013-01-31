package CIDER::Schema::ResultSet::Object;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use CIDER::Logic::Utils;

use Carp qw/croak/;

sub root_objects {
    my $self = shift;
    my $resultset = $self->search(
        { parent => undef },
        { order_by => 'number' },
    );

    if ( wantarray ) {
        return map { $_->type_object } $resultset->all;
    }
    else {
        return $resultset;
    }
}

# Returns a DBIC resultset with one row per root object, but every such object will be
# enhanced with additional data suitable for rendering a detailed list without the need
# to run any further DB queries. See root/display_object.tt for usage example.
sub root_objects_sketch {
    my $self = shift;
    my $resultset = $self->search(
        { 'me.parent' => undef },
        $OBJECT_SKETCH_SEARCH_ATTRIBUTES,
    );

    if ( wantarray ) {
        return $resultset->all;
    }
    else {
        return $resultset;
    }
}

# TO DO: move these to ResultSet::TypeObject?

sub update {
    my $self = shift;

    my $ret = $self->next::method( @_ );

    # TO DO: update audit trail?

    $self->result_source->schema->indexer->update_rs( $self );

    return $ret;
}

sub delete {
    my $self = shift;

    my $ret = $self->next::method( @_ );

    $self->result_source->schema->indexer->remove_rs( $self );

    return $ret;
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
