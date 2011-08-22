use strict;
use warnings;
use utf8;
use Test::More;

# See:  http://www.effectiveperlprogramming.com/blog/1226
if ( Test::Builder->VERSION < 2 ) {
    foreach my $method ( qw(output failure_output) ) {
        binmode Test::More->builder->$method, ':encoding(UTF-8)';
    }
}

use_ok 'Test::WWW::Mechanize::Catalyst', 'CIDER';

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
my $schema = CIDERTest->init_schema;

my $mech = Test::WWW::Mechanize::Catalyst->new;

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
    documentation => 1,
    'collection_primary_record_contexts_1.record_context', => 2,
    'collection_secondary_record_contexts_1.record_context', => 1,
} }, 'Submitted creation form' );

$mech->content_contains( 'You have successfully created' );

my $obj = $schema->resultset( 'Object' )->find( { number => '69105' } );
is( $obj->audit_trail->created_by->first_name, 'Alice',
    'Created by alice.' );
is( $obj->type_object->languages->first->language_name, 'English',
    'Default language is English.' );

$mech->content_contains( '"selected">Context 1',
                         'Record context was selected.' );

$mech->submit_form_ok( { with_fields => {
    number => '42',
} }, 'Submitted update form' );

$obj = $schema->resultset( 'Object' )->find( { number => '42' } );
use DateTime;
is( $obj->audit_trail->modification_logs->first->date, DateTime->today,
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

$mech->submit_form_ok( { with_fields => {
    'languages_1.language' => 'ger',
    'languages_2.language' => 'fre',
} }, 'Set multiple languages' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );
is( $mech->value( 'languages_1.language' ), 'ger', 'German was set.' );
is( $mech->value( 'languages_2.language' ), 'fre', 'French was set.' );

$mech->submit_form_ok( { with_fields => {
    'languages_1.language' => '',
    'languages_2.language' => 'fre',
} }, 'Delete German' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );
is( $mech->value( 'languages_1.language' ), 'fre', 'German was deleted.' );

$mech->submit_form_ok( { with_fields => { type => 'item' } },
                       'Asked for sub-item creation form' );
$mech->content_contains( 'Create a new item' );

$mech->submit_form_ok( { with_fields => {
    title => 'Æthelred the Unready',
    number => 'II',
    circa => 1,
    date_from => '0968',
    date_to => '1016-04-23',
    dc_type => 1,
# TO DO: these are on classes now
#    accession_date => '2011-06',
#    stabilization_date => '9999',
} }, 'Created a sub-item with partial dates' );

$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );
$mech->content_contains( 'Æthelred' );
$mech->content_like( qr/\b0968\b/ );
#$mech->content_like( qr/\b2011-06\b/ );

my $child = $schema->resultset( 'Object' )->find( { number => 'II' } );
is( $child->parent->id, $obj->id, 'Item has correct parent.' );

$mech->content_contains( '42 New test collection',
                         'Breadcrumb trail includes number.' );

# TO DO: test moving to a new parent
# TO DO: test moving to root

$mech->get( '/object/9999' );
is( $mech->status, 404, 'Invalid object number gives 404 page.' );

$mech->get( '/object/n1' );
$mech->content_contains( 'does not belong' );
$mech->submit_form_ok( { with_fields => {
    set_id => 1,
} }, 'Add to set' );
$mech->content_contains( 'belongs to the following' );
$mech->has_tag( a => 'Test Set 1' );

$mech->get( '/object/n1' );
$mech->submit_form_ok( { with_fields => {
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
is( $csv->[0]->{ type }, 'collection',
    'Collection type is correct' );
is( $csv->[0]->{ notes }, 'Test notes.  Unicode: « ☃ ° » yay.',
    'Collection notes are correct' );
is( $csv->[1]->{ title }, 'Test Series 1',
    'Series title is correct' );
is( $csv->[1]->{ type }, 'series',
    'Series type is correct' );
is( $csv->[1]->{ parent }, $csv->[0]->{ number },
    "Child's parent is parent's number" );
is( $csv->[2]->{ type }, 'item',
    'Item type is correct' );

$mech->get( '/object/n1' );
$mech->submit_form_ok ( { with_fields => {
    descendants => 1,
    template => 'export.xml',
} }, 'Export to XML' );
is( $mech->ct, 'application/xml', 'MIME type is correct' );

use XML::LibXML;
ok( XML::LibXML->load_xml( string => $mech->content ),
    'Export file is valid XML' );

done_testing();
