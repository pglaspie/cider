package CIDER::Schema::Result::DigitalObjectApplication;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::DigitalObjectApplication

=cut

__PACKAGE__->table( 'digital_object_application' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    digital_object =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    digital_object =>
        'CIDER::Schema::Result::DigitalObject',
);

__PACKAGE__->add_columns(
    application =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->application() }, fallback => 1;

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

sub delete {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->collection->object );

    return $self;
}

1;
