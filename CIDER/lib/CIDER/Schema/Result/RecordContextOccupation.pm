package CIDER::Schema::Result::RecordContextOccupation;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextOccupation

=cut

__PACKAGE__->table( 'record_context_occupation' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    record_context =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    record_context =>
        'CIDER::Schema::Result::RecordContext',
);

__PACKAGE__->has_many(
    titles =>
        'CIDER::Schema::Result::OccupationTitle',
    'occupation',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', size => 10 },
    date_to =>
        { data_type => 'varchar', is_nullable => 1, size => 10 },
);

1;
