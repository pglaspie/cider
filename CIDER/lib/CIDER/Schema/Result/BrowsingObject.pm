package CIDER::Schema::Result::BrowsingObject;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::ItemClass';

=head1 NAME

CIDER::Schema::Result::BrowsingObject

=cut

__PACKAGE__->table( 'browsing_object' );

__PACKAGE__->setup_item;

__PACKAGE__->add_columns(
    format =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    format =>
        'CIDER::Schema::Result::Format',
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar', is_nullable => 1 },
    thumbnail_pid =>
        { data_type => 'varchar', is_nullable => 1 },
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    browsing_object_relationships =>
        'CIDER::Schema::Result::BrowsingObjectRelationship',
    'browsing_object',
);

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for $self->browsing_object_relationships;

    return $self->next::method( @_ );
}

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->update_format_from_xml_hashref(
        $hr );
    $self->update_text_from_xml_hashref(
        $hr, 'pid' );
    $self->update_text_from_xml_hashref(
        $hr, 'thumbnail_pid' );

    $self->update_or_insert;

    # This needs to be done after the row is inserted, so its id can
    # be used as a foreign key.
    $self->update_relationships_from_xml_hashref( $hr );

    return $self;
}

1;
