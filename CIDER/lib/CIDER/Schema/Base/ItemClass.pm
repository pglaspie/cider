package CIDER::Schema::Base::ItemClass;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Base::ItemClass

=head1 DESCRIPTION

Generic base class for item classes.

=cut

sub setup_item {
    my ( $class ) = @_;

    $class->add_column(
        id =>
            { data_type => 'int', is_auto_increment => 1 },
    );
    $class->set_primary_key( 'id' );

    $class->add_column(
        item =>
            { data_type => 'int', is_foreign_key => 1 },
    );
    $class->belongs_to(
        item =>
            'CIDER::Schema::Result::Item',
    );
}

1;
