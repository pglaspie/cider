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

use_ok( 'CIDER::Controller::Auth' );

# Have 'alice' log in to the site.
$mech->get_ok('/auth/login', 'Hit the login page');
$mech->content_like(qr/log in/, 'Login page looks good');

# It doesn't matter what we pass in here, since the test site is configured to accept
# any input as a valid LDAP user. The controller will still check that the user
# exists in the local database, though.
$mech->submit_form_ok(
    {
        with_fields => {
            username => 'alice',
            password => 'foo',
        },
        button => 'submit',
    },
    'Submitted login form',
);

$mech->content_contains( 'Welcome, alice.' );

done_testing();
