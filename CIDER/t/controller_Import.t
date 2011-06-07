use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'CIDER::Controller::Import' }

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

use Text::CSV::Slurp;
sub test_import {
    my $csv = Text::CSV::Slurp->create( input => [ @_ ] );
    $mech->get_ok( '/import' );
    $mech->submit_form_ok( { with_fields => {
        # This magic is needed to upload a file without actually
        # making a file.  From the WWW::Mechanize docs.
        file => [ [ undef, 'import.csv', Content => $csv ], 1 ]
    } }, 'Submit file to be imported' );
}

test_import( {
    id => 4,
    parent => 3,
    title => 'Test import renaming',
    number => 999,
}, {
    parent => 4,
    title => 'Test import creation',
    number => 69105,
} );

$mech->content_contains( 'successfully imported 2 rows' );

$mech->get_ok( '/object/4' );
$mech->content_contains( 'Test import renaming' );
$mech->content_contains( '999' );

$mech->follow_link_ok( { text => 'Test import creation' } );
$mech->content_contains( '69105' );

test_import( {
    parent => 4,
    title => 'Test import error',
    # no number, required field
} );
$mech->content_contains( 'import failed' );

$mech->get_ok( '/object/4' );
$mech->content_lacks( 'Test import error' );

test_import( { number => 88 } );
$mech->content_contains( 'import failed' );

done_testing();
