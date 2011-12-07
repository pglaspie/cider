#!/usr/bin/perl

# Tests of CIDER object importing.

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

use CIDER::Logic::Importer;
use FindBin;

my $importer = CIDER::Logic::Importer->new(
    schema => $schema,
    rngschema_file => "$FindBin::Bin/../schema/cider-import.rng",
);

isa_ok ($importer, 'CIDER::Logic::Importer');

sub test_import {
    my ( $xml ) = @_;
    open my $handle, '<', \$xml;
    $importer->import_from_xml( $handle );
}

test_import( <<END
<import>
  <create>
    <!-- Comments are ignored here. -->
    <location locationID="xyz">
      <titles><title>Test location creation via XML import</title></titles>
      <unitType>Digital objects</unitType>
    </location>
  </create>
  <!-- Comments are ignored here too. -->
  <update>
    <location locationID="xyz">
      <collectionNumbers><number>c123</number></collectionNumbers>
    </location>
  </update>
</import>
END
);

ok( my $loc = $schema->resultset( 'Location' )->find( { barcode => 'xyz' } ),
    'Imported a new location.' );
is_deeply( [ $loc->collection_numbers ], [ 'c123' ],
           'Updated the location.' );

lives_ok {
    test_import( <<END
<import>
  <create>
    <item number="123">
      <title>New item</title>
      <date>2000</date>
      <classes><group/></classes>
    </item>
  </create>
</import>
END
);
} 'Restrictions and accession number are optional for items.';

test_import( <<END
<import>
  <update>
    <item number="n4">
      <accessionNumber/>
    </item>
  </update>
</import>
END
);
my $item = $schema->resultset( 'Item' )->find( 4 );
is( $item->accession_number, undef,
    'Item accession number removed.' );

throws_ok {
    test_import( <<END
<import>
  <create>
    <series number="n1">
      <title>duplicate number</title>
    </series>
  </create>
</import>
END
);
} qr/import failed at line 3/,
    'Error message includes line number.';

throws_ok {
    test_import( '<import><create><series number="88" /></create></import>' );
} qr/invalid/,
    'Title required on create.';

throws_ok {
    test_import( <<END
<import>
  <update>
    <collection number="">
      <title>No number</title>
    </collection>
  </update>
</import>
END
);
} qr/invalid/,
    "Number can't be empty on update.";

throws_ok {
    test_import( <<END
<import>
  <create>
    <collection number="123">
      <title>New collection</title>
      <documentation>yes</documentation>
    </collection>
  </create>
</import>
END
);
} qr/invalid/,
    "Collection processing status can't be missing on create.";

throws_ok {
    test_import( <<END
<import>
  <create>
    <collection number="123">
      <title>New collection</title>
      <processingStatus>minimal</processingStatus>
    </collection>
  </create>
</import>
END
);
} qr/invalid/,
    "Collection documentation can't be missing on create.";

throws_ok {
    test_import( <<END
<import>
  <create>
    <series>
      <title>New unnumbered series</title>
    </series>
  </create>
</import>
END
);
} qr/invalid/,
    "Number can't be missing on create.";

# date is temporarily not required, while importing legacy data.
#
# throws_ok {
#     test_import( <<END
# <import>
#   <create>
#     <item number="123">
#       <title>New undated item</title>
#       <restrictions>none</restrictions>
#       <accessionNumber>2000.001</accessionNumber>
#       <classes><group/></classes>
#     </item>
#   </create>
# </import>
# END
# );
# } qr/invalid/,
#     "Item date can't be missing on create.";

throws_ok {
    test_import( <<END
<import>
  <update>
    <item number="n4">
      <date>1-1-2001</date>
    </item>
  </update>
</import>
END
);
} qr/invalid/,
    'Date format must be ISO-8601.';

throws_ok {
    test_import( <<END
<import>
  <update>
    <item number="n4">
      <classes>
        <digitalObject>
          <location>8001</location>
          <pid>123</pid>
          <fileCreationDate>2001-01-32</fileCreationDate>
        </digitalObject>
      </classes>
    </item>
  </update>
</import>
END
);
} qr/invalid/,
    'File creation date format must be ISO-8601.';

throws_ok {
    test_import( <<END
<import>
  <update>
    <collection number="n1">
      <permanentURL>invalid:uri</permanentURL>
    </collection>
  </update>
</import>
END
);
} qr/invalid/,
    'Permanent URL must be an http or https URI.';

lives_ok {
    test_import( <<END
<import>
  <update>
    <collection number="n1">
      <permanentURL>https://example.com</permanentURL>
    </collection>
  </update>
</import>
END
);
} 'HTTPS permanent URL is ok.';

lives_ok {
    test_import( <<END
<import>
  <update>
    <collection number="n1">
      <permanentURL></permanentURL>
    </collection>
  </update>
</import>
END
);
} 'Permanent URL can be unset.';

lives_ok {
test_import( <<END
<import>
  <update>
    <series number="n3" parent="n2" />
  </update>
  <update>
    <series number="n3" parent="" />
  </update>
</import>
END
);
} 'libxml2 bug is fixed (or workarounded).';

throws_ok {
test_import( <<END
<import>
  <update>
    <collection number="n1">
      <documentation>true</documentation>
    </collection>
  </update>
</import>
END
);
} qr/invalid/,
    'Documentation must be yes or no.';

throws_ok {
test_import( <<END
<import>
  <update>
    <collection number="n1">
      <publicationStatus>final</publicationStatus>
    </collection>
  </update>
</import>
END
);
} qr/invalid/,
    "Publication status can't be 'final'.";

throws_ok {
test_import( <<END
<import>
  <update>
    <item number="n4">
      <personalNames>
        <personalName>
          <name>George Washington</name>
          <note>Line1
                Line2</note>
        </personalName>
      </personalNames>
    </item>
  </update>
</import>
END
);
} qr/invalid/,
    "Authority term note can't be multiline.";

# TO DO:
#
# check max lengths?
# test changing type

done_testing;
