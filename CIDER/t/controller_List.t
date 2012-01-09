use strict;
use warnings;
use Test::More;

use_ok 'Test::WWW::Mechanize::Catalyst', 'CIDER';
use_ok 'CIDER::Controller::List';

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use CIDERTest;
CIDERTest->init_schema;

my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get( '/' );
$mech->submit_form( with_fields => {
    username => 'alice',
    password => 'foo',
} );

$mech->get_ok( '/list' );

$mech->has_tag_like( 'a', qr/n1 Test Collection with kids, 2000-01-01.*2010-01-01/ );
$mech->has_tag( 'a', 'n2 Test Collection without kids' );

done_testing;
