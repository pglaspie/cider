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
my $item = $schema->resultset( 'Item' )->find( 5 );
$homog_set->add( $item );
my $series = $schema->resultset( 'Series' )->find( 3 );
$heterog_set->add( $series );

$mech->follow_link_ok( { text => 'Sets' } );

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
$mech->follow_link( text => 'Sets' );

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

# Testing set deletion.
# First, just try to delete this set, and make sure it vanishes from the list.
# Then, navigate to a set with objects in it, and perform a recursive delete.
# Make sure both that set and its objects are all gone.
$mech->submit_form_ok( { with_fields => {
    delete => 'Delete this set',
} }, 'Hit the delete button' );
$mech->content_lacks( 'Test Set 1' );
$mech->content_contains( 'Test Set 2' );
my $non_deleted_item = $schema->resultset( 'Item' )->find( 4 );
ok ( defined $non_deleted_item, "Deleting Set 1 didn't delete its contents" );

$mech->follow_link_ok( { text => 'Test Set 2' } );
$mech->submit_form_ok( { with_fields => {
    recursive_delete => 'Recursively delete this set',
    confirm_recursive_delete => 1,
} }, 'Hit the recursive-delete button' );

$mech->content_lacks( 'Test Set 2' );
my $deleted_item = $schema->resultset( 'Item' )->find( 5 );
ok ( not (defined $deleted_item), "Deleting Set 2 did delete its contents" );


done_testing();
