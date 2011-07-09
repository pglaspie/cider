use strict;
use warnings;
use Test::More;

use_ok 'Test::WWW::Mechanize::Catalyst', 'CIDER';
use_ok 'CIDER::Controller::Authority';

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
CIDERTest->init_schema;

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->follow_link_ok( { text => 'Browse authority lists' } );

$mech->follow_link_ok( { text => 'Names' } );
$mech->content_contains( 'Test Name' );
$mech->back;

$mech->follow_link_ok( { text => 'Geographic Terms' } );
$mech->content_contains( 'Test Geographic Term' );
$mech->back;

$mech->follow_link_ok( { text => 'Topic Terms' } );
$mech->content_contains( 'Test Topic Term' );
$mech->back;

$mech->follow_link_ok( { text => 'Formats' } );
$mech->content_contains( 'Test Format' );
$mech->back;

$mech->get( '/authority/foobar' );
is( $mech->status, 404, 'Unknown list goes to 404' );
$mech->back;

$mech->follow_link( text => 'Names' );
$mech->submit_form_ok( { with_fields => {
    note => 'New Note',
} }, 'Submit form with no name' );
$mech->content_contains( 'is required' );
$mech->submit_form_ok( { with_fields => {
    name => 'New Name',
    note => 'New Note',
} }, 'Submit form with name' );
$mech->content_contains( 'Added' );
$mech->content_contains( '<td>New Name' );
$mech->content_contains( '<td>New Note' );

done_testing();
