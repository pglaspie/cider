package CIDER::Schema::ResultSet::ObjectSet;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Carp qw/croak/;

__PACKAGE__->load_components("Helper::ResultSet::SetOperations");

1;

