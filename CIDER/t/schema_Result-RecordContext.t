#!/usr/bin/perl

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

my $rc = $schema->resultset( 'RecordContext' )->find( 1 );
is( $rc->name_entry, 'Context 1',
    'Context 1 name_entry is correct.' );
is( $rc->rc_type, 'corporateBody',
    'Context 1 rc_type is correct.' );

$schema->resultset( 'RecordContext')->create( {
    record_id => 'RCR00023',
    name_entry => 'Context 23',
    rc_type => 1,
} );

$rc = $schema->resultset( 'RecordContext' )->find( { record_id => 'RCR00023' } );
my $trail = $rc->audit_trail;
is( $trail->created_by->user->id, 1,
    'Context 23 created by user 1.' );
is( $trail->date_created, DateTime->today,
    'Creation date is today.' );

$rc->update( { name_entry => 'Updated context' } );
my $logs = $trail->modification_logs;
is( $logs->count, 1, 'Modified once.' );
is( $logs->first->user->id, 1, 'Modified by user 1.' );

$rc->export;
is( $trail->date_available, DateTime->today, 'Date available is today.' );

$rc->delete;
is( $schema->resultset( 'AuditTrail' )->find( $trail->id ), undef,
    'Audit trail was deleted.' );

done_testing;
