package CIDER::Schema::Result::Application;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Application

=cut

__PACKAGE__->table( 'application' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    function =>
        { data_type => 'enum',
          extra => { list => [ qw(
                                     checksum
                                     media_image
                                     virus_check
                             ) ] } },
);

__PACKAGE__->has_many(
    checksum_digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    'checksum_app',
);

__PACKAGE__->has_many(
    media_image_digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    { 'foreign.media_app' => 'self.id' },
);

__PACKAGE__->has_many(
    virus_check_digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    { 'foreign.virus_app' => 'self.id' },
);

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    [ { 'foreign.checksum_app' => 'self.id' },
      { 'foreign.media_app'    => 'self.id' },
      { 'foreign.virus_app'    => 'self.id' },
    ],
);

__PACKAGE__->many_to_many(
    items =>
        'digital_objects',
    'item'
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name }, fallback => 1;


sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
