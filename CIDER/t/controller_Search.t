use strict;
use warnings;
use Test::More;

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
CIDERTest->init_schema;

use_ok( 'CIDER::Controller::Search' );

use Test::WWW::Mechanize::Catalyst 'CIDER';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->get_ok( '/search' );
$mech->submit_form_ok( { with_fields => {
    query => 'Item',
} }, 'Search for Item in any field.' );
$mech->content_contains( '"Item" returned 2 objects', 'Found 2 Items.' );
$mech->content_contains( 'Test Item 1', 'Found Test Item 1.' );
$mech->content_contains( 'Test Item 2', 'Found Test Item 2.' );

$mech->submit_form_ok( { with_fields => { name => 'from_search_1' } },
                       'Submitting the create-set-from-search form.' );
$mech->follow_link_ok( { text => 'from_search_1' }, 'Created a new set.' );
$mech->content_contains( 'Test Item 1', 'Found Test Item 1.' );
$mech->content_contains( 'Test Item 2', 'Found Test Item 2.' );

$mech->get( '/search' );
$mech->submit_form_ok( { with_fields => {
    field => 'title',
    query => 'Item',
} }, 'Search for Item in title.' );
$mech->content_contains( '"title:(Item)" returned 2 objects', 'Found 2 Items.' );

$mech->submit_form_ok( { with_fields => { name => 'from_search_2' } },
                       'Submitting the create-set-from-search form.' );
$mech->follow_link_ok( { text => 'from_search_2' }, 'Created a new set.' );
$mech->content_contains( 'Test Item 1', 'Found Test Item 1.' );
$mech->content_contains( 'Test Item 2', 'Found Test Item 2.' );

$mech->get( '/search' );
$mech->submit_form_ok( { with_fields => {
    field => 'title',
    query => 'Item AND 1',
} }, 'Search for Item and 1 in title.' );
$mech->content_contains( '"title:(Item AND 1)" returned 1 object',
                         'Found 1 Item 1.' );

$mech->get( '/search' );
$mech->submit_form_ok( { with_fields => {
    query => 'title:Item AND volume:NULL',
} }, 'Search for title:Item and no description.' );
$mech->content_contains( 'returned 1 object',
                         'Found 1 item with no volume.' );
                         
done_testing;
