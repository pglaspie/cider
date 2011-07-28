package CIDER::Schema::Result::Location;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Location;

=cut

__PACKAGE__->table( 'location' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    titles =>
        'CIDER::Schema::Result::LocationTitle',
);

__PACKAGE__->has_many(
    collection_numbers =>
        'CIDER::Schema::Result::LocationCollectionNumber',
);

__PACKAGE__->has_many(
    series_numbers =>
        'CIDER::Schema::Result::LocationSeriesNumber',
);

__PACKAGE__->add_columns(
    barcode =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'barcode' ] );

__PACKAGE__->add_columns(
    unit_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    unit_type =>
        'CIDER::Schema::Result::UnitType',
    undef,
    { proxy => 'volume' }
);

1;
