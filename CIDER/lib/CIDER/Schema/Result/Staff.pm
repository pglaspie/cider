package CIDER::Schema::Result::Staff;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Staff

=cut

__PACKAGE__->table( 'staff' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    { 'foreign.stabilized_by' => 'self.id' },
);

__PACKAGE__->has_many(
    logs =>
        'CIDER::Schema::Result::Log',
);

__PACKAGE__->might_have(
    user =>
        'CIDER::Schema::Result::User',
);

__PACKAGE__->add_columns(
    first_name =>
        { data_type => 'varchar' },
    last_name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->full_name }, fallback => 1;

sub full_name {
    my $self = shift;
    return $self->last_name . ', ' . $self->first_name;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
