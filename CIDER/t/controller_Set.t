use strict;
use warnings;
use Test::More;

use_ok( 'CIDER::Controller::Set' );

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;

use Test::WWW::Mechanize::Catalyst 'CIDER';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

my $user = $schema->resultset( 'User' )->find( 1 );
my ( $homog_set, $heterog_set ) = $user->sets;
my $item = $schema->resultset( 'Object' )->find( 5 );
$homog_set->add( $item );
my $series = $schema->resultset( 'Object' )->find( 3 );
$heterog_set->add( $series );

$mech->follow_link_ok( { text => 'Your sets' } );

$mech->follow_link_ok( { text => 'Test Set 2' } );
$mech->content_contains( 'Test Series 1' );
$mech->content_contains( 'Test Item 2' );
$mech->content_lacks( 'Set every' );
$mech->content_lacks( 'In every' );

use Text::CSV::Slurp;
$mech->submit_form_ok( { with_fields => {
    descendants => 1,
    template => 'export.csv',
} }, 'Export to CSV' );
ok( my $csv = Text::CSV::Slurp->load( string => $mech->content ),
    'Export file is valid CSV' );
is( @$csv, 4, 'CSV has four rows.' );
$mech->back;

$mech->submit_form_ok( { form_number => 1 }, 'Remove the first item' );
$mech->content_lacks( 'Test Series 2' );
$mech->content_contains( 'Set every' );
$mech->follow_link( text => 'Your sets' );

$mech->follow_link_ok( { text => 'Test Set 1' } );
$mech->content_contains( 'Test Item 1' );
$mech->content_contains( 'Test Item 2' );

$mech->submit_form_ok( { with_fields => {
    field => 'title',
    value => 'Same Title',
} }, 'Submitted the batch-edit form' );
$mech->content_like( qr/Same Title.*Same Title/s );
$mech->content_lacks( 'Test Item' );

$mech->submit_form_ok( { with_fields => {
    field => 'title',
    old_value => 'Same',
    new_value => 'Different',
} }, 'Submitted the search-and-replace form' );
$mech->content_contains( '2 items' );
$mech->submit_form_ok( { form_number => 1 }, 'Hit the confirm button' );

$mech->content_like( qr/Different Title.*Different Title/s );
$mech->content_lacks( 'Same Title' );

$mech->submit_form_ok( { with_fields => {
    delete => 'Delete',
} }, 'Hit the delete button' );
$mech->content_lacks( 'Test Set 1' );
$mech->content_contains( 'Test Set 2' );

done_testing();
