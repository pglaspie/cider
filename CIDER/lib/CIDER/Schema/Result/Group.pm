package CIDER::Schema::Result::Group;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::ItemClass';

=head1 NAME

CIDER::Schema::Result::Group

=cut

__PACKAGE__->table( 'item_group' );

__PACKAGE__->setup_item;

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    return $self->update_or_insert;
}

=head2 volume

Returns the number of sub-items in this group.

=cut

sub volume {
    my $self = shift;

    return scalar $self->item->children;
}

1;
