package CIDER::Schema::Result::Group;

use strict;
use warnings;

use base 'CIDER::Schema::Base::ItemClass';

=head1 NAME

CIDER::Schema::Result::Group

=cut

__PACKAGE__->table( 'item_group' );

__PACKAGE__->setup_item;

1;
