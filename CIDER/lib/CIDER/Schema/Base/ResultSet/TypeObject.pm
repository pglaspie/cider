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
    return $obj->type_object->update_from_xml( $elt );
}

1;
