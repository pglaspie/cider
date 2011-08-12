#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

use Test::More;
use DateTime;

$schema->resultset( 'Item' )->create( {
    number    => 12345,
    title     => 'Test Item 3',
    date_from => '2000-01-01',
    dc_type   => 1,
} );

ok( my $obj = $schema->resultset( 'Object' )->find( { number => 12345 } ),
    'Created test item 3.' );
my $item = $obj->type_object;

# TO DO: test store_column
# TO DO: test changing type

my $trail = $item->audit_trail;

is( $trail->created_by->user->id, 1,
    'Created by user 1.' );

is( $trail->date_created, DateTime->today,
    'Creation date is today.' );

$item->update( { number => 54321 } );
my $logs = $trail->modification_logs;
is( $logs->count, 1, 'Modified once.' );
is( $logs->first->user->id, 1, 'Modified by user 1.' );

done_testing;
