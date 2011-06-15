use strict;
use warnings;
use Test::More;

eval "use Test::WWW::Mechanize::Catalyst 'CIDER'";
if ($@) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst required';
    exit 0;
}

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
CIDERTest->init_schema;
CIDERTest->init_index;

ok( my $mech = Test::WWW::Mechanize::Catalyst->new, 'Created mech object' );

use_ok( 'CIDER::Controller::Search' );

$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->get_ok( '/search' );
$mech->submit_form_ok( { with_fields => {
    field => 'title',
    query => 'Item',
} }, 'Search for Item.' );
$mech->content_contains( 'returned 2 objects', 'Found 2 Items.' );
$mech->content_contains( 'Test Item 1', 'Found Test Item 1.' );
$mech->content_contains( 'Test Item 2', 'Found Test Item 2.' );

done_testing();
