package CIDER::Schema::Result::FileFolder;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::ItemClass';

=head1 NAME

CIDER::Schema::Result::FileFolder

=cut

__PACKAGE__->table( 'file_folder' );

__PACKAGE__->setup_item;

__PACKAGE__->add_columns(
    location =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    location =>
        'CIDER::Schema::Result::Location',
);

__PACKAGE__->add_columns(
    notes =>
        { data_type => 'text', is_nullable => 1 },
);

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->update_location_from_xml_hashref( $hr );
    $self->update_text_from_xml_hashref( $hr, 'notes' );

    return $self->update_or_insert;
}

=head2 format

Returns the string "File (document grouping)" (since that is the only
format applicable to this class).

=cut

sub format {
    return 'File (document grouping)';
}

1;
