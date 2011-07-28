package CIDER::Schema::Result::BrowsingObject;

use strict;
use warnings;

use base 'CIDER::Schema::Base::ItemClass';

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
    undef,
    { where => { class => 'browsing_object' } }
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

1;
