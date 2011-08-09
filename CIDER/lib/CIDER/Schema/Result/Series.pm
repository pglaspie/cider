package CIDER::Schema::Result::Series;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

=head1 NAME

CIDER::Schema::Result::Series

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'series' );

__PACKAGE__->resultset_class( 'CIDER::Schema::Base::ResultSet::TypeObject' );

__PACKAGE__->setup_object;

__PACKAGE__->add_columns(
    bulk_date_from =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    bulk_date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
    description =>
        { data_type => 'text', is_nullable => 1 },
    arrangement =>
        { data_type => 'text', is_nullable => 1 },
    notes =>
        { data_type => 'text', is_nullable => 1 },
);

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'series';
}

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    $self->object->update_from_xml( $elt );

    # TO DO: update columns

    return $self->update_or_insert;
}

1;
