package CIDER::Schema::Result::OccupationTitle;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::OccupationTitle

=cut

__PACKAGE__->table( 'occupation_title' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    occupation =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    occupation =>
        'CIDER::Schema::Result::RecordContextOccupation',
);

__PACKAGE__->add_columns(
    title =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->title }, fallback => 1;

1;
