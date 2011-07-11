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

use_ok( 'CIDER::Controller::Object' );

$mech->get_ok( '/object' );

$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->submit_form_ok( { with_fields => { type => 'collection' } },
    'Asked for collection creation form' );

$mech->content_contains( 'Create a new collection' );

$mech->content_contains( 'Esperanto', 'Language list is populated.' );

$mech->submit_form_ok( { with_fields => {
    title => 'New test collection',
    number => '69105',
    processing_status => 1,
    has_physical_documentation => 1,
} }, 'Submitted creation form' );

$mech->content_contains( 'You have successfully created' );

my $rs = $schema->resultset( 'Collection' )->search( { number => '69105' } );
is( $rs->first->created_by->username, 'alice', 'Created by alice.' );

$mech->submit_form_ok( { with_fields => {
    number => '42',
} }, 'Submitted update form' );

$rs = $schema->resultset( 'Collection' )->search( { number => '42' } );
use DateTime;
is( $rs->first->modification_logs->first->date, DateTime->today,
    'Date modified is today.' );

$mech->submit_form_ok( { with_fields => {
    bulk_date_from => '12-31-1999',
    bulk_date_to => '2003/01/13',
} }, 'Use incorrect date formats' );
$mech->content_contains( 'Sorry', 'Form submission error.' );
$mech->content_like( qr(date must be.*date must be.)s, 'Two error messages.' );

$mech->submit_form_ok( { with_fields => {
    bulk_date_from => '1999-12-31',
    bulk_date_to => '2003-01-13',
} }, 'Use correct date format' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );

$mech->submit_form_ok( { with_fields => {
    bulk_date_from => '1999-12',
    bulk_date_to => '2003',
} }, 'Partial dates' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );

$mech->get_ok( $mech->uri );
$mech->content_contains( 'value="1999-12"', 'From date correct.' );
$mech->content_contains( 'value="2003"', 'To date correct.' );

$mech->submit_form_ok( { with_fields => { type => 'item' } },
                       'Asked for sub-item creation form' );
$mech->content_contains( 'Create a new item' );

$mech->submit_form_ok( { with_fields => {
    title => 'Æthelred the Unready',
    number => 'II',
    circa => 1,
    date_from => '0968',
    date_to => '1016-04-23',
    accession_date => '2011-06',
    type => 1,
    stabilization_date => '9999',
} }, 'Created a sub-item with partial dates' );

$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );
$mech->content_contains( 'Æthelred' );
$mech->content_like( qr/\b0968\b/ );
$mech->content_like( qr/\b2011-06\b/ );

$mech->get( '/object/9999' );
is( $mech->status, 404, 'Invalid object id gives 404 page.' );

$mech->get( '/object/1' );
$mech->submit_form_ok ( { with_fields => {
    descendants => 1,
    template => 'export.csv',
} }, 'Export to CSV' );
is( $mech->ct, 'text/csv', 'MIME type is correct' );

use Text::CSV::Slurp;
ok( my $csv = Text::CSV::Slurp->load( string => $mech->content ),
    'Export file is valid CSV' );
is( @$csv, 4, 'CSV has four rows.' );
is( $csv->[0]->{ title }, 'Test Collection with kids',
    'Collection title is correct' );
is( $csv->[1]->{ title }, 'Test Series 1',
    'Series title is correct' );
is( $csv->[1]->{ parent }, $csv->[0]->{ number },
    "Child's parent is parent's number" );

$mech->get( '/object/1' );
$mech->submit_form_ok ( { with_fields => {
    descendants => 1,
    template => 'export.xml',
} }, 'Export to XML' );
is( $mech->ct, 'application/xml', 'MIME type is correct' );

use XML::LibXML;
ok( XML::LibXML->load_xml( string => $mech->content ),
    'Export file is valid XML' );

done_testing();
