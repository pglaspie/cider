package CIDER::Schema::Result::Format;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Format

=cut

__PACKAGE__->table( 'format' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    class =>
        { data_type => 'enum',
          extra => { list => [ qw(
                                     container
                                     bound_volume
                                     three_dimensional_object
                                     audio_visual_media
                                     document
                                     physical_image
                                     digital_object
                                     browsing_object
                             ) ] } },
);

__PACKAGE__->has_many(
    containers =>
        'CIDER::Schema::Result::Container',
    'format',
);

__PACKAGE__->has_many(
    bound_volumes =>
        'CIDER::Schema::Result::BoundVolume',
    'format',
);

__PACKAGE__->has_many(
    three_dimensional_objects =>
        'CIDER::Schema::Result::ThreeDimensionalObject',
    'format',
);

__PACKAGE__->has_many(
    audio_visual_media =>
        'CIDER::Schema::Result::AudioVisualMedia',
    'format',
);

__PACKAGE__->has_many(
    documents =>
        'CIDER::Schema::Result::Document',
    'format',
);

__PACKAGE__->has_many(
    physical_images =>
        'CIDER::Schema::Result::PhysicalImage',
    'format',
);

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    # TO DO: why can't we just say 'format' here?
    { 'foreign.format' => 'self.id' },
);

__PACKAGE__->has_many(
    browsing_objects =>
        'CIDER::Schema::Result::BrowsingObject',
    'format',
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_unique_constraint( [ qw(class name) ] );

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
