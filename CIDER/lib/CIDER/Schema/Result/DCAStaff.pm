package CIDER::Schema::Result::DCAStaff;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::DCAStaff

=cut

__PACKAGE__->table( 'dca_staff' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    'stabilized_by',
);

__PACKAGE__->add_columns(
    first_name =>
        { data_type => 'varchar' },
    last_name =>
        { data_type => 'varchar' },
);
use overload '""' => sub {
    my $self = shift;
    return $self->last_name . ', ' . $self->first_name;
}, fallback => 1;


sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
