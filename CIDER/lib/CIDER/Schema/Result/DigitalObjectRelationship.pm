package CIDER::Schema::Result::DigitalObjectRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::DigitalObjectRelationship;

=cut

__PACKAGE__->table( 'digital_object_relationship' );

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
    predicate =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    predicate =>
        'CIDER::Schema::Result::RelationshipPredicate',
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar' },
);

1;
