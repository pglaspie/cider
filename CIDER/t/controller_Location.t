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

# TO DO: locations are on item classes now.

# $mech->get( '/object/4/' );
# $mech->submit_form_ok( { with_fields => {
#     location => '1234',
# } }, 'Update an item with a new location barcode.' );
# is( $mech->uri->path, '/location/1234/create',
#     'Redirected to create location.' );
# $mech->content_contains( 'after which', 'Not-done-yet alert message.' );
# $mech->content_contains( 'Test Item 1', 'Mentions item title.' );
# $mech->content_contains( 'updated' );

# $mech->submit_form_ok( { with_fields => {
#     'titles_1.title' => 'Title 1234',
#     unit_type => 1,
# } }, 'Create new location.' );
# is( $mech->uri->path, '/object/4', 'Redirected to item detail.' );

# $mech->get( '/object/create/item' );
# $mech->submit_form_ok( { with_fields => {
#     title => 'New Test Item',
#     number => '99',
#     date_from => '2000-01-01',
#     dc_type => 1,
#     location => '2345',
# } }, 'Create an item with a new location barcode.' );
# is( $mech->uri->path, '/location/2345/create',
#     'Redirected to create location.' );
# $mech->content_contains( 'after which', 'Not-done-yet alert message.' );
# $mech->content_contains( 'New Test Item', 'Mentions item title.' );
# $mech->content_contains( 'created' );

# $mech->submit_form_ok( { with_fields => {
#     'titles_1.title' => 'Title 2345',
#     unit_type => 1,
# } }, 'Create new location.' );
# like( $mech->uri->path, qr(/object/[0-9]+), 'Redirected to item detail.' );
# $mech->content_contains( 'successfully', 'Successful creation.' );
# $mech->content_contains( '2345', 'Location is filled in.' );

# $mech->submit_form_ok( { with_fields => {
#     location => '',
# } }, 'Remove location.' );
# $mech->content_lacks( '2345', 'Successfully removed location.' );

done_testing();
