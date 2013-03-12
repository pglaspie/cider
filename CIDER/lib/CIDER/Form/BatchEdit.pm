package CIDER::Form::BatchEdit;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::TraitFor::Model::DBIC';
use Moose::Util::TypeConstraints;

# We don't actually make use of a passed-in ObjectSet here, but this must be set anyway
# to make HTML::FormHandler::TraitFor::Model::DBIC happy. And when it's happy, we can
# get the options for certain <select> fields straight from the DB, which is indeed
# what we want.
has '+item_class' => ( default => 'ObjectSet' );

use Readonly;
Readonly my @CLASS_OPTIONS => (
    {
        value => 'audio_visual_media',
        label => 'Audio-visual media',
    },
    {
        value => 'bound_volumes',
        label => 'Bound volumes',
    },
    {
        value => 'browsing_objects',
        label => 'Browsing objects',
    },
    {
        value => 'containers',
        label => 'Containers',
    },
    {
        value => 'documents',
        label => 'Documents',
    },
    {
        value => 'digital_objects',
        label => 'Digital objects',
    },
    {
        value => 'file_folders',
        label => 'File Folders',
    },
    {
        value => 'physical_images',
        label => 'Physical images',
    },

    {
        value => 'three_dimensional_objects',
        label => 'Three dimensional objects',
    },



);

has_field 'field' => ( type => 'Select',
                       required => 1,
                       empty_select => 'Choose a field to edit...',
                     options => [
                                {
                                    value => 'title',
                                    label => 'Title',
                                },
                                {
                                    value => 'accession',
                                    label => 'Accession number',
                                },
                                {
                                    value => 'description',
                                    label => 'Description',
                                },
                                {
                                    value => 'restriction',
                                    label => 'Restrictions',
                                },
                                {
                                    value => 'creator',
                                    label => 'Creators',
                                },
                                {
                                    value => 'dc_type',
                                    label => 'DC type',
                                },
                                {
                                    value => 'rights',
                                    label => 'Rights',
                                },
                                {
                                    value => 'format',
                                    label => 'Format',
                                },
                            ],
                        );

has_field 'title_kind' => ( type => 'Select',
                            widget => 'RadioGroup',
                            options => [
                                {
                                    value => 'replace',
                                    label => 'Change the title of each object in this '
                                             . 'set to some new title',
                                    attributes => { class => 'title_kind' },
                                },
                                {
                                    value => 'edit',
                                    label => 'Apply a certain text change to the title '
                                             . 'of every object in this set',
                                    attributes => { class => 'title_kind' },
                                },
                            ],
                           );
has_field 'title_new_title' => ( type => 'Text',
                                 label => 'New title',
                                      required_when => {
                                        title_kind => 'replace',
                                        field => 'title',
                                     },
                               );
has_field 'title_incorrect_text' => ( type => 'Text',
                                      label => 'Text to replace',
                                      required_when => {
                                        title_kind => 'edit',
                                        field => 'title',
                                     },
                                    );
has_field 'title_corrected_text' => ( type => 'Text',
                                      label => 'Text to replace it with',
                                      required_when => {
                                        title_kind => 'edit',
                                        field => 'title',
                                     },
                                     );
has_field 'accession_kind' => ( type => 'Select',
                            widget => 'RadioGroup',
                            options => [
                                {
                                    value => 'new',
                                    label => 'Add a new accession number to the '
                                             . 'accession number list of each object '
                                             . 'in this set',
                                    attributes => { class => 'accession_kind' },
                                },
                                {
                                    value => 'edit',
                                    label => 'Given a certain accession number, replace '
                                             . 'every occurrence of that number within '
                                             . 'this set with a new number',
                                    attributes => { class => 'accession_kind' },
                                },
                            ],
                           );
has_field 'accession_new_number' => ( type => 'Text',
                                 label => 'New number',
                                      required_when => {
                                        accession_kind => 'new',
                                        field => 'accession',
                                     },
                               );
has_field 'accession_incorrect_number' => ( type => 'Text',
                                      required_when => {
                                        accession_kind => 'edit',
                                        field => 'accession',
                                     },
                                      label => 'Number to replace',
                                    );
has_field 'accession_corrected_number' => ( type => 'Text',
                                      required_when => {
                                        accession_kind => 'edit',
                                        field => 'accession',
                                     },
                                      label => 'Number to replace it with',
                                    );

has_field 'description_kind' => ( type => 'Select',
                            widget => 'RadioGroup',
                            options => [
                                {
                                    value => 'replace',
                                    label => 'Change the description of each object in this '
                                             . 'set to some new description',
                                    attributes => { class => 'description_kind' },
                                },
                                {
                                    value => 'edit',
                                    label => 'Apply a certain text change to the description '
                                             . 'of every object in this set',
                                    attributes => { class => 'description_kind' },
                                },
                            ],
                           );
has_field 'description_new_description' => ( type => 'TextArea',
                                 label => 'New description',
                                      required_when => {
                                        description_kind => 'replace',
                                        field => 'description',
                                     },
                               );
has_field 'description_incorrect_text' => ( type => 'Text',
                                      label => 'Text to replace',
                                      required_when => {
                                        description_kind => 'edit',
                                        field => 'description',
                                     },
                                    );
has_field 'description_corrected_text' => ( type => 'Text',
                                      label => 'Text to replace it with',
                                      required_when => {
                                        description_kind => 'edit',
                                        field => 'description',
                                     },
                                     );

has_field 'restriction' => ( type => 'Select',
                             required_when => { field => 'restriction' },
                             label => "Set all objects' restriction to:",
                             empty_select => 'Choose a restriction...',
                        );

sub options_restriction {
    my $self = shift;
    my %options;
    for my $restriction ( $self->schema->resultset( 'ItemRestrictions' )->all ) {
        $options{ $restriction->id } = $restriction->description;
    }
    return %options;
}

has_field 'creator_name_and_note' => ( type => 'Text',
                         required_when => { field => 'creator' },
                         label => 'Add a new creator:',
                         element_class => [ 'authority_name' ],
                         );

has_field 'creator_name' => ( type => 'Hidden',
                            required_when => { field => 'creator' },
                            );

has_field 'dc_type' => ( type => 'Select',
                         required_when => { field => 'dc_type' },
                         empty_select => 'Choose a type...',
                        );

sub options_dc_type {
    my $self = shift;
    my %options;
    for my $dc_type ( $self->schema->resultset( 'DCType' )->all ) {
        $options{ $dc_type->id } = $dc_type->name;
    }
    return %options;
}

has_field 'rights_class' => ( type => 'Select',
                              empty_select => 'Choose a class...',
                              required_when => { field => 'rights' },
                              options => \@CLASS_OPTIONS,
                            );

has_field 'rights' => ( type => 'TextArea',
                        required_when => { field => 'rights' },
                    );


has_field 'format_class' => ( type => 'Select',
                              empty_select => 'Choose a class...',
                              required_when => { field => 'format' },
                              options => \@CLASS_OPTIONS,
                            );

has_field 'format' => ( type => 'Select',
                        empty_select => 'Choose a format...',
                        required_when => { field => 'format' },
                    );

sub options_format {
    my $self = shift;
    my @options;
    for my $format ( $self->schema
                     ->resultset( 'Format' )
                     ->search(
                        undef,
                        { order_by => 'class, name', },
                     )
                     ->all ) {
        my $class_attribute = _pluralize( $format->class );

        my $option = {
            value => $format->id,
            label => $format->class . ': ' . $format->name,
            attributes => {
                class => $class_attribute,
            },
        };
        push @options, $option;
    }
    return @options;
}

# Ugly thing to stick an 's' on some class names when needed.
sub _pluralize {
    my ( $class_name ) = @_;
    if ( $class_name =~ /media$/ ) {
        return $class_name;
    }
    else {
        return "${class_name}s";
    }
}

has_field 'edit_button' => ( type => 'Submit' );

1;
