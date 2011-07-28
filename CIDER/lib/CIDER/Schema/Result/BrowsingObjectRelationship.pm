package CIDER::Schema::Result::BrowsingObjectRelationship;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::BrowsingObjectRelationship;

=cut

__PACKAGE__->table( 'browsing_object_relationship' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    browsing_object =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    browsing_object =>
        'CIDER::Schema::Result::BrowsingObject',
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
