package CIDER::Schema::Result::Series;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'CIDER::Schema::Result::Object';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CIDER::Schema::Result::Series

=cut

__PACKAGE__->table("object");

__PACKAGE__->add_columns(
);

1;
