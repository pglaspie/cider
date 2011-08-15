package CIDER::Schema::Result::ItemTopicTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::ItemTopicTerm

=cut

__PACKAGE__->table( 'item_topic_term' );

__PACKAGE__->add_columns(
    item =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    item =>
        'CIDER::Schema::Result::Item',
);

__PACKAGE__->add_columns(
    term =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    term =>
        'CIDER::Schema::Result::TopicTerm',
);

__PACKAGE__->set_primary_key( qw( item term ) );

1;
