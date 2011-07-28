package CIDER::Schema::Result::FileFolder;

use strict;
use warnings;

use base 'CIDER::Schema::Base::ItemClass';

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

1;
