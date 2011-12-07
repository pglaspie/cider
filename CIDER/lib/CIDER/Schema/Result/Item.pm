package CIDER::Schema::Result::Item;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

use String::CamelCase qw( camelize decamelize );

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
        { data_type => 'varchar', size => 10,
          # date_from is temporarily not required, while importing legacy data.
          is_nullable => 1,
        },
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
    'term',
);

__PACKAGE__->has_many(
    item_geographic_terms =>
        'CIDER::Schema::Result::ItemGeographicTerm',
);
__PACKAGE__->many_to_many(
    geographic_terms =>
        'item_geographic_terms',
    'term',
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

sub classes {
    my $self = shift;

    my @classes = (
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
    return @classes;
}

=head2 insert

Override TypeObject->insert to set default values.

=cut

sub insert {
    my $self = shift;

    $self->dc_type( undef ) unless defined $self->dc_type;

    return $self->next::method( @_ );
}

=head2 store_column( $column, $value )

Override store_column to set default values.

=cut

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    if ( !defined( $value ) || $value eq '' ) {
        if ( $column eq 'circa' ) {
            $value = 0;
        }
        elsif ( $column eq 'dc_type' ) {
            my $rs = $self->result_source->related_source( $column )->resultset;
            $value = $rs->find( { name => 'Text' } )->id;
        }
    }

    return $self->next::method( $column, $value );
}

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for (
        $self->item_authority_names,
        $self->item_topic_terms,
        $self->item_geographic_terms,
        $self->classes,
    );

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

    $self->object->update_from_xml( $elt, $hr );

    # Text elements

    $self->update_boolean_from_xml_hashref(
        $hr, 'circa' );
    $self->update_dates_from_xml_hashref(
        $hr, 'date' );
    $self->update_text_from_xml_hashref(
        $hr, 'accession_number' );
    $self->update_text_from_xml_hashref(
        $hr, 'description' );
    $self->update_text_from_xml_hashref(
        $hr, 'volume' );
    $self->update_text_from_xml_hashref(
        $hr, 'issue' );
    $self->update_text_from_xml_hashref(
        $hr, 'abstract' );
    $self->update_text_from_xml_hashref(
        $hr, 'citation' );

    # Controlled vocabulary elements

    $self->update_cv_from_xml_hashref(
        $hr, 'restrictions' );
    $self->update_cv_from_xml_hashref(
        $hr, 'dc_type' );

    $self->update_or_insert;

    # Repeatables - These have to be done after the row is inserted,
    # so that its id can be used as a foreign key.

    $self->update_terms_from_xml_hashref(
        $hr, creators => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, personal_names => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, corporate_names => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, topic_terms => 'term' );
    $self->update_terms_from_xml_hashref(
        $hr, geographic_terms => 'term' );

    if ( exists $hr->{ classes } ) {
        $_->delete for $self->classes;
        my $schema = $self->result_source->schema;
        for my $class_elt ( @{ $hr->{ classes } } ) {
            my $rel = decamelize( $class_elt->tagName );
            $rel = "${rel}s" unless $rel eq 'audio_visual_media';
            my $class = $self->new_related( $rel, { } );
            $class->update_from_xml( $class_elt );
        }
    }

    $self->update_audit_trail_from_xml_hashref( $hr );

    return $self;
}

=head2 update_terms_from_xml_hashref( $hr, $relname, $proxy )

Update an authority term many-to-many relationship from an XML element
hashref.  $relname converted to mixed case is the tagname of the child
element on $hr.  Its children have 'name' and (optional) 'note'
elements, which are used to lookup/create/update the appropriate
authority term.  $proxy is the name of the column on the link class
that points to the authority term class.

=cut

sub update_terms_from_xml_hashref {
    my $self = shift;
    my ( $hr, $relname, $proxy ) = @_;

    my $tag = lcfirst( camelize( $relname ) );
    $relname = "item_$relname";
    my $irs = $self->result_source->related_source( $relname );
    my $rs = $irs->related_source( $proxy )->resultset;
    if ( exists( $hr->{ $tag } ) ) {
        $self->delete_related( $relname );
        for my $term_elt ( @{ $hr->{ $tag } } ) {
            my $term_hr = $self->xml_to_hashref( $term_elt );
            my $term = $rs->find( { name => $term_hr->{ name } } );
            if ( $term ) {
                if ( exists $term_hr->{ note } ) {
                    $term->update( { note => $term_hr->{ note } } );
                }
            }
            else {
                $term = $rs->create( $term_hr );
            }
            $self->create_related( $relname, { $proxy => $term } );
        }
    }
}

1;
