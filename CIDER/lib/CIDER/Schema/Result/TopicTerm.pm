package CIDER::Schema::Result::TopicTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::TopicTerm

=cut

__PACKAGE__->table( 'topic_term' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    item_topic_terms =>
        'CIDER::Schema::Result::ItemTopicTerm',
    'term',
);
__PACKAGE__->many_to_many(
    items =>
        'item_topic_terms',
    'item',
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    note =>
        { data_type => 'text', is_nullable => 1 },
);

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
