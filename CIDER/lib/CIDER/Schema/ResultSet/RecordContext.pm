package CIDER::Schema::ResultSet::RecordContext;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use XML::LibXML;
use Carp;

sub create_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $id = $elt->getAttribute( 'recordID' );
    if ( $self->find( { record_id => $id } ) ) {
        croak "A record context with recordID '$id' already exists.";
    }
    my $loc = $self->new_result( { record_id => $id } );
    return $loc->update_from_xml( $elt );
}

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $id = $elt->getAttribute( 'recordID' );
    my $loc = $self->find( { record_id => $id } );
    unless ( $loc ) {
        croak "There is no record context whose recordID is '$id'.";
    }
    return $loc->update_from_xml( $elt );
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
