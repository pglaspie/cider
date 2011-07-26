package CIDER::Schema::Result::CollectionRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::CollectionRelationship;

=cut

__PACKAGE__->table( 'collection_relationship' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    collection =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    collection => 'CIDER::Schema::Result::Object',
);

__PACKAGE__->add_columns(
    predicate =>
        { data_type => 'tinyint', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    predicate => 'CIDER::Schema::Result::RelationshipPredicate',
);

__PACKAGE__->add_columns(
    pid =>
        { data_type => 'varchar' },
);

1;
