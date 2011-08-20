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

sub test_import {
    my ( $xml ) = @_;
    $mech->get_ok( '/import' );
    $mech->submit_form_ok( { with_fields => {
        # This magic is needed to upload a file without actually
        # making a file.  From the WWW::Mechanize docs.
        file => [ [ undef, 'import.xml', Content => $xml ], 1 ]
    } }, 'Submit file to be imported' );
}

test_import( <<END
<import>
  <update>
    <series number="n3">
      <title>Test import renaming</title>
    </series>
  </update>
  <create>
    <series number="69105" parent="n3">
      <title>Test import creation</title>
    </series>
  </create>
</import>
END
);

$mech->content_contains( 'successfully imported' );
$mech->content_contains( 'created 1 object and updated 1 object' );

$mech->get_ok( '/object/3' );
$mech->content_contains( 'Test import renaming' );
$mech->content_contains( 'n3' );

$mech->follow_link_ok( { text_regex => qr/Test import creation/ } );
$mech->content_contains( '69105' );

test_import( <<END
<import>
  <update>
    <series number="n3" parent="n3">
      <title>Test import error</title>
    </series>
  </update>
</import>
END
);

$mech->content_contains( 'import failed' );
$mech->content_contains( 'its own parent' );

$mech->get_ok( '/object/3' );
$mech->content_lacks( 'Test import error' );

test_import( <<END
<import>
  <create>
    <series number="88" />
  </create>
</import>
END
);

$mech->content_contains( 'invalid' );

done_testing();
