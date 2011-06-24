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

my $obj = $schema->resultset( 'Object' )->find( 1 );
is( $obj->created_by->id, 1,
    'Object 1 created by user 1.' );
is( $obj->date_created, DateTime->new( year => 2011, month => 1, day => 1 ),
    'Object 1 created on 2011-01-01.' );
is( $obj->date_available, DateTime->new( year => 2011, month => 5, day => 1 ),
    'Object 1 available on 2011-05-01.' );

$schema->user( 1 );
$obj = $schema->resultset( 'Object' )->create( {
    number    => 12345,
    title     => 'Test Item 3',
    date_from => '2000-01-01',
    date_to   => '2010-01-01',
} );

ok( $obj, 'Created test item 3.' );

is( $obj->created_by->id, 1, 'Created by user 1.' );

use DateTime;
is( $obj->date_created, DateTime->today, 'Creation date is today.' );

$obj->update( { number => 54321 } );

my $logs = $obj->modification_logs;
is( $logs->count, 1, 'Modified once.' );
is( $logs->first->user->id, 1, 'Modified by user 1.' );

$obj->export;

is( $obj->date_available, DateTime->today, 'Date available is today.' );
