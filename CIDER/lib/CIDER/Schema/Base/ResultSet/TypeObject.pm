package CIDER::Schema::Base::ResultSet::TypeObject;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use XML::LibXML;
use Carp qw( croak );

=head1 NAME

CIDER::Schema::Result::Base::ResultSet::TypeObject

=head1 DESCRIPTION

Generic base class for type-specific resultsets, i.e. Collection,
Series, and Item.

=cut

sub create_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $rs = $self->result_source->related_source( 'object' )->resultset;
    my $id = $elt->getAttribute( 'number' );
    if ( $rs->find( { number => $id } ) ) {
        croak "An object with number '$id' already exists.";
    }
    my $obj = $self->new_result( { number => $id } );
    return $obj->update_from_xml( $elt );
}

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $rs = $self->result_source->related_source( 'object' )->resultset;
    my $id = $elt->getAttribute( 'number' );
    my $obj = $rs->find( { number => $id } );
    unless ( $obj ) {
        croak "Object number '$id' does not exist.";
    }
    my $type_obj = $obj->type_object;
    my $type = $elt->tagName;
    if ( $type ne $type_obj->type ) {
        # This is a type change: replace the old type object with a new one.
        $type_obj->delete( 1 ); # don't delete $obj!
        $type_obj = $obj->new_related( $type, { } );
    }
    return $type_obj->update_from_xml( $elt );
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
