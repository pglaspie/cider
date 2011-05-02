use strict;
use warnings;
use Test::More;

eval "use Test::WWW::Mechanize::Catalyst 'CIDER'";
if ($@) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst required';
    exit 0;
}
use_ok( 'CIDER::Controller::Set' );

ok( my $mech = Test::WWW::Mechanize::Catalyst->new, 'Created mech object' );

$mech->get_ok( 'http://localhost/set' );
done_testing();
