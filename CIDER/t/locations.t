#!/usr/bin/perl

# Tests of CIDER location objects.

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);     

use CIDERTest;
my $schema = CIDERTest->init_schema;

use Test::More qw(no_plan);

ok( my $loc = $schema->resultset( 'Location' )->find( '8001' ),
    'Location found.' );
is( $loc->unit_type->name, '1.2 cu. ft. box',
    'Location is a box.' );
is( $loc->volume, 1.2,
    'Location volume is 1.2 cu. ft.' );
is_deeply( [ $loc->titles ], [ 'John Doe Papers', 'Jane Doe Papers' ],
           'Location has correct two titles.' );
