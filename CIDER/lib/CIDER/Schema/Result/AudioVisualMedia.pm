package CIDER::Schema::Result::AudioVisualMedia;

use strict;
use warnings;

use base 'CIDER::Schema::Base::ItemClass';

=head1 NAME

CIDER::Schema::Result::AudioVisualMedia

=cut

__PACKAGE__->table( 'audio_visual_media' );

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
        'CIDER::Schema::Result::Format',
    undef,
    { where => { class => 'audio_visual_media' } }
);

__PACKAGE__->add_columns(
    notes =>
        { data_type => 'text', is_nullable => 1 },
    rights =>
        { data_type => 'text', is_nullable => 1 },
);

1;
