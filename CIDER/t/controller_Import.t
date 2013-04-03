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

$mech->get_ok( '/object/n3' );
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

$mech->get_ok( '/object/n3' );
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

# Testing class batch-updates.
# At this point in the test, item 'n4' possesses one digital object class.
# Item 'n5' has no classes at all.
my $n4 = $schema->resultset( 'Item' )->find( 4 );
is ( $n4->classes, 1, 'Item n4 begins with one class' );

test_import ( <<END
<import>
    <update>
        <item number="n4">
            <classes>
                <boundVolume action="create">
                    <location>9003</location>
                </boundVolume>
            </classes>
        </item>
    </update>
</import>
END
);
$n4->discard_changes;
is ( $n4->classes, 2, 'Added a new class to an item via batch-update' );

test_import ( <<END
<import>
    <update>
        <item number="n5">
            <classes>
                <digitalObject action="update">
                    <location>8002</location>
                    <pid>somePid</pid>
                </digitalObject>
            </classes>
        </item>
    </update>
</import>
END
);
my $n5 = $schema->resultset( 'Item' )->find( 5 );
is ( $n5->classes, 0, 'Replacing classes on a classless item is a no-op' );

test_import ( <<END
<import>
    <update>
        <item number="n4">
            <classes>
                <digitalObject action="update">
                    <location>8002</location>
                    <pid>somePid</pid>
                </digitalObject>
            </classes>
        </item>
    </update>
</import>
END
);
$n4->discard_changes;
is ( $n4->digital_objects, 1,
     "After replacing DOs, n4 still has only one DO." );
is ( $n4->bound_volumes, 1,
     "After replacing DOs, n4 still has one browsing object." );
is ( ( $n4->digital_objects )[0]->location->barcode, '8002',
      "The DO's location changed as expected." );

test_import ( <<END
<import>
    <update>
        <item number="n4">
            <classes>
                <digitalObject action="create">
                    <location>9003</location>
                    <pid>somePid</pid>
                    <notes>Hello there.</notes>
                </digitalObject>
            </classes>
        </item>
    </update>
</import>
END
);
$n4->discard_changes;

is ( $n4->digital_objects, 2, "After adding a new DO, n4 has two of them." );
is ( $n4->bound_volumes, 1, "Adding a new DO didn't kill n4's bound volume." );
is ( ( $n4->digital_objects )[0]->location->barcode, '8002',
       "First DO's location is correct." );
is ( ( $n4->digital_objects )[1]->location->barcode, '9003',
       "Second DO's (different) location is correct." );

test_import ( <<END
<import>
    <update>
        <item number="n4">
            <classes>
                <digitalObject action="update">
                    <location>8002</location>
                    <pid>somePid</pid>
                </digitalObject>
            </classes>
        </item>
    </update>
</import>
END
);
$n4->discard_changes;
is ( $n4->digital_objects, 2, 'After updating DOs, n4 still has only two DOs.' );
is ( $n4->bound_volumes, 1, "Replacing DOs didn't kill n4's bound volume." );
is ( ( $n4->digital_objects )[0]->location->barcode, '8002',
       "First DO's location barcode matches the new value." );
is ( ( $n4->digital_objects )[1]->location->barcode, '8002',
       "Second DO's location barcode matches the new value." );
is ( ( $n4->digital_objects )[1]->notes, 'Hello there.', "Notes are left untouched." );
is ( ( $n4->bound_volumes )[0]->location->barcode, '9003',
       "Bound Volume's location barcode left untouched." );

done_testing();
