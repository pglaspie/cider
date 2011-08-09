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

my $rs = $schema->resultset( 'Location' );

$rs->update_from_xml( elt <<END
<location locationID="8001">
  <seriesNumbers><number>s1</number></seriesNumbers>
</location>
END
);

my $loc = $rs->find( 1 );
is_deeply( [ $loc->series_numbers ], [ 's1' ],
           'Updated location 8001 from XML.' );

throws_ok {
    $rs->update_from_xml( elt '<location locationID="xyz" />' )
} qr/no location/,
    'Location not found.';

$loc = $rs->create_from_xml( elt <<END
<location locationID="xyz">
  <titles><title>Test create from XML</title></titles>
  <unitType>Digital objects</unitType>
</location>
END
);

is_deeply( [ $loc->titles, $loc->unit_type ],
           [ 'Test create from XML', 'Digital objects' ],
           'Created location from XML.' );

throws_ok {
    $rs->create_from_xml( elt <<END
<location locationID="xyz">
  <titles><title>Test create from XML</title></titles>
  <unitType>Digital objects</unitType>
</location>
END
);
} qr/already exists/,
    'Location already exists';

done_testing;
