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
    has_physical_documentation => 1,
} }, 'Submitted creation form' );

$mech->content_contains( 'You have successfully created' );

my $rs = $schema->resultset( 'Collection' )->search( { number => '69105' } );
is( $rs->first->creator->username, 'alice', 'Creator is alice.' );

$mech->submit_form_ok( { with_fields => {
    number => '42',
} }, 'Submitted update form' );

$rs = $schema->resultset( 'Collection' )->search( { number => '42' } );
use DateTime;
is( $rs->first->modification_logs->first->date, DateTime->today,
    'Date modified is today.' );

$mech->submit_form_ok( { with_fields => {
    bulk_date_from => '12-31-1999',
    bulk_date_to => '2003/1/13',
} }, 'Use incorrect date formats' );
$mech->content_contains( 'Sorry', 'Form submission error.' );
$mech->content_like( qr(Invalid date.*Invalid date.)s, 'Two error messages.' );

$mech->submit_form_ok( { with_fields => {
    bulk_date_from => '1999-12-31',
    bulk_date_to => '2003-1-13',
} }, 'Use correct date format' );
$mech->content_lacks( 'Sorry', 'Form submitted successfully.' );

$mech->get_ok( $mech->uri );
$mech->content_contains( 'value="1999-12-31"', 'From date correct.' );
$mech->content_contains( 'value="2003-01-13"', 'To date correct.' );

done_testing();
