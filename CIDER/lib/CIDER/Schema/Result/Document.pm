package CIDER::Schema::Result::Document;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::ItemClass';

=head1 NAME

CIDER::Schema::Result::Document

=cut

__PACKAGE__->table( 'document' );

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
    format =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    format =>
        'CIDER::Schema::Result::Document',
);

__PACKAGE__->add_columns(
    dimensions =>
        { data_type => 'varchar', is_nullable => 1 },
    rights =>
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

    $self->update_cv_from_xml_hashref(
        $hr, location => 'barcode' );
    $self->update_format_from_xml_hashref(
        $hr );
    $self->update_text_from_xml_hashref(
        $hr, 'dimensions' );
    $self->update_text_from_xml_hashref(
        $hr, 'rights' );

    return $self->update_or_insert;
}

1;
