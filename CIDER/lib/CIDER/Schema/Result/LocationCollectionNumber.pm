package CIDER::Schema::Result::LocationCollectionNumber;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::LocationCollectionNumber;

=cut

__PACKAGE__->table( 'location_collection_number' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    location =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    location =>
        'CIDER::Schema::Result::Location',
);

__PACKAGE__->add_columns(
    number =>
        { data_type => 'varchar' }
);

use overload '""' => sub { shift->number() }, fallback => 1;

1;
