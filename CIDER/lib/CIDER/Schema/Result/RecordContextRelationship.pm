package CIDER::Schema::Result::RecordContextRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::RecordContextRelationship;

=cut

__PACKAGE__->table( 'record_context_relationship' );

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

__PACKAGE__->add_columns(
    type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    type =>
        'CIDER::Schema::Result::RecordContextRelationshipType',
);

__PACKAGE__->add_columns(
    related_entity =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    related_entity =>
        'CIDER::Schema::Result::RecordContext',
);

__PACKAGE__->add_columns(
    date_from =>
        { data_type => 'varchar', size => 10, is_nullable => 1 },
    date_to =>
        { data_type => 'varchar', size => 10, is_nullable => 1 },
);

1;
