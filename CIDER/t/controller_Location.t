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
my $schema = CIDERTest->init_schema;

ok( my $mech = Test::WWW::Mechanize::Catalyst->new, 'Created mech object' );

use_ok( 'CIDER::Controller::Location' );

$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->get( '/location/123' );
is( $mech->status, 404, 'Nonexistent location, page not found' );

$mech->get_ok( '/location/8001' );

$mech->content_contains( 'bound', 'Unit type list is populated.' );

$mech->content_contains( 'John', 'Location has first title.' );
$mech->content_contains( 'Jane', 'Location has second title.' );

$mech->get( '/location/create' );
is( $mech->status, 404, 'Create with no barcode, page not found' );

$mech->get_ok( '/location/8001/create' );
is( $mech->uri->path, '/location/8001',
    'Create existing barcode, redirects to detail page.' );

$mech->get_ok( '/location/123/create' );
$mech->submit_form_ok( { with_fields => {
    'titles_1.title' => 'Title 123',
    unit_type => 1,
} }, 'Create new location.' );

$mech->content_contains( 'Title 123', 'Location title was set.' );

$mech->submit_form_ok( { with_fields => {
    'titles_2.title' => 'Second Title',
} }, 'Set second title.' );
$mech->content_contains( 'Second Title', 'Second location title was set.' );

$mech->get( '/object/4/' );
$mech->submit_form_ok( { with_fields => {
    location => '1234',
} }, 'Update an item with a new location barcode.' );
$mech->content_contains( 'successfully', 'Successful update.' );
is( $mech->uri->path, '/location/1234/create',
    'Redirected to create location.' );

$mech->submit_form_ok( { with_fields => {
    'titles_1.title' => 'Title 1234',
    unit_type => 1,
} }, 'Create new location.' );
$mech->content_contains( 'successfully', 'Successful creation.' );
$mech->content_contains( 'Test Item 1', 'Links back to item.' );

done_testing();
