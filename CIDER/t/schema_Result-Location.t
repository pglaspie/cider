#!/usr/bin/perl

# Tests of CIDER location objects.

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;

use Test::More;
use Test::Exception;

use XML::LibXML;

ok( my $loc = $schema->resultset( 'Location' )->find( { barcode => '8001' } ),
    'Location found.' );
is( $loc->unit_type->name, '1.2 cu. ft. box',
    'Location is a box.' );
is( $loc->volume, 1.2,
    'Location volume is 1.2 cu. ft.' );
is_deeply( [ $loc->titles ], [ 'John Doe Papers', 'Jane Doe Papers' ],
           'Location has correct two titles.' );

$loc->update_from_xml( elt <<END
<location>
  <titles><title>New title</title></titles>
  <collectionNumbers><number>c1</number><number>c2</number></collectionNumbers>
  <unitType>Bound volume</unitType>
</location>
END
);

is_deeply( [ $loc->titles ], [ 'New title' ],
           'New title set.' );
is( $schema->resultset( 'LocationTitle' )->count, 1,
    'Old titles deleted.' );
is_deeply( [ $loc->collection_numbers ], [ 'c1', 'c2' ],
           'Collection numbers added.' );
is( $loc->unit_type->name, 'Bound volume',
    'Unit type set.' );

$loc->update_from_xml( elt '<location><collectionNumbers/></location>' );

is( $loc->collection_numbers, 0, 'Collection numbers removed.' );

done_testing;
