#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

use Test::More;
use Test::Exception;

my $rs = $schema->resultset( 'Collection' );

$rs->update_from_xml( elt <<END
<collection number="n1">
  <title>Renamed collection</title>
</collection>
END
);

$rs->create_from_xml( elt <<END
<collection number="41">
  <title>Brand-new collection</title>
  <documentation>yes</documentation>
  <processingStatus>minimal</processingStatus>
</collection>
END
);

my @collections = $schema->resultset( 'Object' )->root_objects;
is( scalar @collections, 3,
    'After import, there are three root objects.' );
is( $collections[1]->title, 'Renamed collection',
    'After import, the modified collection has been renamed.');
is( $collections[2]->title, 'Test Collection without kids',
    'After import, the untouched collection has the expected name.');
is( $collections[0]->title, 'Brand-new collection',
    'After import, the new collection has the expected name.');

throws_ok {
    $rs->create_from_xml( elt <<END
<collection number="n3">
  <title>Duplicate number</title>
  <documentation>yes</documentation>
  <processingStatus>minimal</processingStatus>
</collection>
END
);
} qr/already exists/,
    'Importing a duplicate number is an error.';

throws_ok {
    $rs->update_from_xml( elt '<collection number="foobar" />' );
} qr/not exist/,
    'Importing an unknown number is an error.';

done_testing;
