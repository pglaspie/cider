use strict;
use warnings;
use Test::More;

use_ok 'Test::WWW::Mechanize::Catalyst', 'CIDER';

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
my $schema = CIDERTest->init_schema;

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

use_ok 'CIDER::Controller::RecordContext';

$mech->follow_link_ok( { text => 'Record contexts' } );

$mech->follow_link_ok( { text => 'RCR00001 Context 1' } );

$mech->has_tag_like( 'a', qr/n1 Test Collection with kids/,
                     'Collections are displayed.' );

$mech->submit_form_ok( { with_fields => {
    name_entry => 'Context 2',
} }, 'Submit update form' );
$mech->content_contains( 'Name entry is already in use' );

$mech->submit_form_ok( { with_fields => {
    record_id => 'RCR00002',
} }, 'Submit update form' );
$mech->content_contains( 'Record ID is already in use' );

$mech->submit_form_ok( { with_fields => {
    record_id => 'RCR00003',
    name_entry => 'Updated Context',
} }, 'Submit update form' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );

is( $schema->resultset( 'RecordContext' )->find( 1 )->name_entry,
    'Updated Context',
    'Name entry was updated.' );

$mech->follow_link_ok( { text => 'Record contexts' } );

$mech->follow_link_ok( { text => 'Create a new record context' } );

$mech->submit_form_ok( { with_fields => {
    record_id => 'RCR00004',
    name_entry => 'New Context',
    date_from => '2011',
    history => 'Sample history',
    'sources_1.source' => 'A trusted source',
} }, 'Submit create form' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );

$mech->follow_link_ok( { text => 'Record contexts' } );

$mech->follow_link_ok( { url_regex => qr/RCR00004/ } );

$mech->content_contains( 'New Context' );

$mech->form_id( 'delete_form' );
$mech->click_ok( 'delete', 'Hit the delete button' );

$mech->content_contains( 'Record contexts' );

$mech->content_lacks( 'New Context' );

done_testing;
