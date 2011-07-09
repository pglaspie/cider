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
} }, 'Submit create form with no name' );
$mech->content_contains( 'is required' );
$mech->submit_form_ok( { with_fields => {
    name => 'New Name',
    note => 'New Note',
} }, 'Submit create form with name' );
$mech->content_contains( 'Added' );
$mech->content_contains( '<td>New Name' );
$mech->content_contains( '<td>New Note' );

$mech->follow_link_ok( { text => 'Edit', url_regex => qr(1) } );
$mech->submit_form_ok( { with_fields => {
    name => '',
    note => 'Another Note',
} }, 'Submit update form with no name' );
$mech->content_contains( 'is required' );
$mech->submit_form_ok( { with_fields => {
    name => 'Another Name',
    note => 'Another Note',
} }, 'Submit update form with name' );
$mech->content_contains( 'Updated' );
$mech->content_contains( '<td>Another Name' );
$mech->content_contains( '<td>Another Note' );
$mech->content_lacks( 'Test Name' );

$mech->follow_link_ok( { text => 'Delete' } );
$mech->content_contains( 'Deleted' );
$mech->content_contains( 'New Name' );
$mech->content_lacks( 'New Note' );

done_testing();
