package CIDER::Schema::ResultSet::Object;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use Carp qw/croak/;

sub root_objects {
    my $self = shift;
    my $resultset = $self->search(
        { parent => undef },
        { order_by => 'title' },
    );

    if ( wantarray ) {
        return $resultset->all;
    }
    else {
        return $resultset;
    }
}

1;

