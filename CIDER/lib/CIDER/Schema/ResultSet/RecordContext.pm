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

1;
