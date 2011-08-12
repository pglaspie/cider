package CIDER::Schema::Result::DigitalObject;

use strict;
use warnings;

use base 'CIDER::Schema::Base::ItemClass';

=head1 NAME

CIDER::Schema::Result::DigitalObject

=cut

__PACKAGE__->table( 'digital_object' );

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
        'CIDER::Schema::Result::DigitalObject',
    undef,
    { where => { class => 'digital_object' } }
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar', is_nullable => 1 },
    permanent_url =>
        { data_type => 'varchar', is_nullable => 1 },
    notes =>
        { data_type => 'text', is_nullable => 1 },
    rights =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    # This can't be called 'relationships' because there's already a
    # method by that name!
    digital_object_relationships =>
        'CIDER::Schema::Result::DigitalObjectRelationship',
    'digital_object',
);

__PACKAGE__->add_columns(
    checksum =>
        { data_type => 'varchar', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    file_extension =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    file_extension =>
        'CIDER::Schema::Result::FileExtension',
);

__PACKAGE__->add_columns(
    original_filename =>
        { data_type => 'varchar', is_nullable => 1 },
    toc =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    stabilized_by =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    stabilized_by =>
        'CIDER::Schema::Result::Staff',
);

__PACKAGE__->add_columns(
    stabilization_date =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

__PACKAGE__->add_columns(
    stabilization_procedure =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    stabilization_procedure =>
        'CIDER::Schema::Result::StabilizationProcedure',
);

__PACKAGE__->add_columns(
    stabilization_notes =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    checksum_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    checksum_app =>
        'CIDER::Schema::Result::Application',
    undef,
    { where => { function => 'checksum' } }
);

__PACKAGE__->add_columns(
    media_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    media_app =>
        'CIDER::Schema::Result::Application',
    undef,
    { where => { function => 'media_image' } }
);

__PACKAGE__->add_columns(
    virus_app =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->belongs_to(
    virus_app =>
        'CIDER::Schema::Result::Application',
    undef,
    { where => { function => 'virus_check' } }
);

__PACKAGE__->has_many(
    other_apps =>
        'CIDER::Schema::Result::DigitalObjectApplication',
    'digital_object',
);

__PACKAGE__->add_columns(
    file_creation_date =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

1;
