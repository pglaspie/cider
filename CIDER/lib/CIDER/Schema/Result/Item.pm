package CIDER::Schema::Result::Item;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

=head1 NAME

CIDER::Schema::Result::Item

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'item' );

__PACKAGE__->resultset_class( 'CIDER::Schema::Base::ResultSet::TypeObject' );

__PACKAGE__->setup_object;

__PACKAGE__->has_many(
    item_creators =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'creator' } }
);
__PACKAGE__->many_to_many(
    creators =>
        'item_creators',
    'name',
);

__PACKAGE__->add_columns(
    circa =>
        { data_type => 'boolean', default_value => 0 },
    date_from =>
        { data_type => 'varchar', size => 10 },
    date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

__PACKAGE__->add_columns(
    restrictions =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    restrictions =>
        'CIDER::Schema::Result::ItemRestrictions',
);

__PACKAGE__->add_columns(
    accession_number =>
        { data_type => 'varchar', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    dc_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    dc_type =>
        'CIDER::Schema::Result::DCType',
);

__PACKAGE__->has_many(
    item_personal_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'personal_name' } }
);
__PACKAGE__->many_to_many(
    personal_names =>
        'item_personal_names',
    'name',
);

__PACKAGE__->has_many(
    item_corporate_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'corporate_name' } }
);
__PACKAGE__->many_to_many(
    corporate_names =>
        'item_corporate_names',
    'name',
);

__PACKAGE__->has_many(
    item_topic_terms =>
        'CIDER::Schema::Result::ItemTopicTerm',
);
__PACKAGE__->many_to_many(
    topic_terms =>
        'item_topic_terms',
    'topic_term',
);

__PACKAGE__->has_many(
    item_geographic_terms =>
        'CIDER::Schema::Result::ItemGeographicTerm',
);
__PACKAGE__->many_to_many(
    geographic_terms =>
        'item_geographic_terms',
    'geographic_term',
);

__PACKAGE__->add_columns(
    description =>
        { data_type => 'text', is_nullable => 1 },
    volume =>
        { data_type => 'varchar', is_nullable => 1 },
    issue =>
        { data_type => 'varchar', is_nullable => 1 },
    abstract =>
        { data_type => 'text', is_nullable => 1 },
    citation =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    groups =>
        'CIDER::Schema::Result::Group',
);

__PACKAGE__->has_many(
    file_folders =>
        'CIDER::Schema::Result::FileFolder',
);

__PACKAGE__->has_many(
    containers =>
        'CIDER::Schema::Result::Container',
);

__PACKAGE__->has_many(
    bound_volumes =>
        'CIDER::Schema::Result::BoundVolume',
);

__PACKAGE__->has_many(
    three_dimensional_objects =>
        'CIDER::Schema::Result::ThreeDimensionalObject',
);

__PACKAGE__->has_many(
    audio_visual_media =>
        'CIDER::Schema::Result::AudioVisualMedia',
);

__PACKAGE__->has_many(
    documents =>
        'CIDER::Schema::Result::Document',
);

__PACKAGE__->has_many(
    physical_images =>
        'CIDER::Schema::Result::PhysicalImage',
);

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
);

__PACKAGE__->has_many(
    browsing_objects =>
        'CIDER::Schema::Result::BrowsingObject',
);


__PACKAGE__->has_many(
    item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
);
__PACKAGE__->many_to_many(
    authority_names =>
        'item_authority_names',
    'name',
);

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'item';
}

=head2 classes

The list of ItemClass objects associated with this item.

=cut

# TO DO: make this a relationship?

sub classes {
    my $self = shift;

    return (
        $self->groups,
        $self->file_folders,
        $self->containers,
        $self->bound_volumes,
        $self->three_dimensional_objects,
        $self->audio_visual_media,
        $self->documents,
        $self->physical_images,
        $self->digital_objects,
        $self->browsing_objects,
    );
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $_->delete for (
        $self->item_authority_names,
        $self->item_topic_terms,
        $self->item_geographic_terms,
        $self->classes,
    );

    $self->next::method( @_ );

    return $self;
}

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    $self->object->update_from_xml( $elt );

    my $hr = $self->xml_to_hashref( $elt );

    if ( exists $hr->{ date } ) {
        my $dateRange = $hr->{ date };
        if ( ref( $dateRange ) eq 'ARRAY' ) {
            $self->date_from( $dateRange->[0]->textContent );
            $self->date_to  ( $dateRange->[1]->textContent );
        }
        else {
            $self->date_from( $dateRange );
        }
    }

    $self->update_cv_from_xml_hashref(
        $hr, dc_type => 'name' );

    # TO DO: other columns & relationships

    return $self->update_or_insert;
}

1;
