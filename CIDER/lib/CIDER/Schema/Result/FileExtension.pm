package CIDER::Schema::Result::FileExtension;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::FileExtension

=cut

__PACKAGE__->table( 'file_extension' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    'file_extension',
);

__PACKAGE__->add_columns(
    extension =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->extension() }, fallback => 1;


sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
}

1;
