package CIDER::Schema::Result::ItemGeographicTerm;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::ItemGeographicTerm

=cut

__PACKAGE__->table( 'item_geographic_term' );

__PACKAGE__->add_columns(
    item =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    item =>
        'CIDER::Schema::Result::Item',
);

__PACKAGE__->add_columns(
    geographic_term =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    geographic_term =>
        'CIDER::Schema::Result::GeographicTerm',
);

__PACKAGE__->set_primary_key( qw( item geographic_term ) );

1;
