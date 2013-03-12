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
$mech->follow_link( text => 'Sets' );

$mech->follow_link_ok( { text => 'Test Set 1' } );
$mech->content_contains( 'Test Item 1' );
$mech->content_contains( 'Test Item 2' );

# Testing batch edits.

$mech->get_ok( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'title',
    title_kind => 'replace',
    title_new_title => 'Same Title',
} } );
$mech->content_like( qr/Same Title.*Same Title/s );
$mech->content_lacks( 'Test Item' );

$mech->get_ok( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field => 'title',
    title_kind => 'edit',
    title_incorrect_text => 'Same',
    title_corrected_text => 'Different',
} } );
$mech->content_like( qr/Different Title.*Different Title/s );
$mech->content_lacks( 'Same Title' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'description',
    description_kind => 'replace',
    description_new_description => 'A brand new description!',
} } );

my $item4 = $schema->resultset('Item')->find( 4 );
is ( $item4->description, 'A brand new description!',
                          'Batch description-replacement works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'description',
    description_kind => 'edit',
    description_incorrect_text => 'description',
    description_corrected_text => 'inscription',
} } );
$item4->discard_changes;
is ( $item4->description, 'A brand new inscription!',
                          'Batch description-edit works' );

my $numbers = $item4->accession_numbers;
$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'accession',
    accession_kind => 'new',
    accession_new_number => '2013.001',
} } );
$item4->discard_changes;
is ( $item4->accession_number, '2011.004, 2013.001',
                          'Batch add-accession-number works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'accession',
    accession_kind => 'edit',
    accession_incorrect_number => '2013.001',
    accession_corrected_number => '2013.999',
} } );
$item4->discard_changes;
is ( $item4->accession_number, '2011.004, 2013.999',
                          'Batch edit-accession-number works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'restriction',
    restriction => '2',
} } );
$item4->discard_changes;
is ( $item4->restrictions->id, '2',
                          'Batch restictions-change works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'creator',
    creator_name_and_note => 'Some Guy',
    creator_name          => '1',
} } );
$item4->discard_changes;
is ( $item4->creators, 1, 'Batch creator-add works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'dc_type',
    dc_type => '2',
} } );
$item4->discard_changes;
is ( $item4->dc_type->id, '2',
                          'Batch DC type-change works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'rights',
    rights_class => 'digital_objects',
    rights => 'Public Domain',
} } );
$item4->discard_changes;
is ( ($item4->digital_objects)[0]->rights, 'Public Domain',
                          'Batch rights-change works' );

$mech->get( '/set/1/batch_edit' );
$mech->submit_form_ok( { with_fields => {
    field      => 'format',
    format_class => 'digital_objects',
    format => '2',
} } );
$item4->discard_changes;
is ( ($item4->digital_objects)[0]->format, 'application/pdf',
                          'Batch format-change works' );

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
