package CIDER::Schema::ResultSet::Location;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use XML::LibXML;
use Carp;

sub create_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $id = $elt->getAttribute( 'locationID' );
    if ( $self->find( { barcode => $id } ) ) {
        croak "A location with locationID '$id' already exists.";
    }
    my $loc = $self->new_result( { barcode => $id } );
    return $loc->update_from_xml( $elt );
}

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $id = $elt->getAttribute( 'locationID' );
    my $loc = $self->find( { barcode => $id } );
    unless ( $loc ) {
        croak "There is no location whose locationID is '$id'.";
    }
    return $loc->update_from_xml( $elt );
}

1;
