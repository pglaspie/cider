package CIDER::Schema::Base::Result::ItemClass;

use strict;
use warnings;

use base 'DBIx::Class::Core';

use Carp;

=head1 NAME

CIDER::Schema::Base::Result::ItemClass

=head1 DESCRIPTION

Generic base class for item classes.

=cut

sub setup_item {
    my ( $class ) = @_;

    $class->load_components( 'UpdateFromXML' );

    $class->add_column(
        id =>
            { data_type => 'int', is_auto_increment => 1 },
    );
    $class->set_primary_key( 'id' );

    $class->add_column(
        item =>
            { data_type => 'int', is_foreign_key => 1 },
    );
    $class->belongs_to(
        item =>
            'CIDER::Schema::Result::Item',
    );
}

=head2 update_location_from_xml_hashref( $hr )

Update a Location column from an XML element hashref.  Throws an error
if the locationID does not refer to an existent Location.

=cut

sub update_location_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ location } ) ) {
        my $barcode = $hr->{ location };
        my $rs = $self->result_source->related_source( 'location' )->resultset;
        my $loc = $rs->find( { barcode => $barcode } );
        unless ( $loc ) {
            croak "Location '$barcode' does not exist.";
        }
        $self->location( $loc );
    }
}

=head2 update_format_from_xml_hashref( $hr )

Update a Format authority list column from an XML element hashref.
The format will be added to the authority list if it doesn't already
exist.

=cut

# TO DO: refactor update_term_from_xml_hashref?

sub update_format_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ format } ) ) {
        my $rs = $self->result_source->related_source( 'format' )->resultset;
        my $obj = $rs->find_or_create( { name => $hr->{ format },
                                         class => $self->table } );
        $self->format( $obj );
    }
}

1;
