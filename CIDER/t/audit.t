#!/usr/bin/perl

# Tests of CIDER audit trail.

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use DateTime;

use CIDERTest;
my $schema = CIDERTest->init_schema;

use Test::More qw(no_plan);

my $obj = $schema->resultset( 'Object' )->create( {
    number    => 12345,
    title     => 'Test Item 3',
    date_from => '2000-01-01',
    date_to   => '2010-01-01',
} );

ok( $obj, 'Created test item 3.' );

$obj->creator( 1 );
is( $obj->creator->id, 1, 'Created by user 1.' );

use DateTime;
is( $obj->date_created, DateTime->today, 'Creation date is today.' );
