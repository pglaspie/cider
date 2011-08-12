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
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

use Test::More;

my $obj = $schema->resultset( 'Object' )->find( 1 )->type_object;
my $trail = $obj->audit_trail;
is( $trail->created_by->user->id, 1,
    'Object 1 created by user 1.' );
is( $trail->date_created, DateTime->new( year => 2011, month => 1, day => 1 ),
    'Object 1 created on 2011-01-01.' );
is( $trail->date_available, DateTime->new( year => 2011, month => 5, day => 1 ),
    'Object 1 available on 2011-05-01.' );
my $logs = $trail->modification_logs;
is( $logs->count, 2, 'Modified twice.' );
is( $logs->first->user->id, 1, 'Modified by user 1.' );

my $new_trail = $schema->resultset( 'AuditTrail' )->create( { } );
$obj->audit_trail( $new_trail );
$obj->update;
$trail->delete;
is( $schema->resultset( 'Log' )->search_rs( { audit_trail => $trail->id } ), 0,
    'Logs were deleted.' );

# TO DO: test import: create/update with/without auditTrail

done_testing;
