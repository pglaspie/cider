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
$schema->user( 1 );

use Test::More;
use Test::Exception;

use CIDER::Logic::Importer;
use FindBin;

my $importer = CIDER::Logic::Importer->new( schema => $schema );

isa_ok ($importer, 'CIDER::Logic::Importer');

sub test_import {
    my ( $xml ) = @_;
    open my $handle, '<', \$xml;
    $importer->import_from_xml( $handle );
}

test_import( <<END
<import>
  <create>
    <location locationID="xyz">
      <titles><title>Test location creation via XML import</title></titles>
      <unitType>Digital objects</unitType>
    </location>
  </create>
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


# TO DO: these are all validation tests

# dies_ok {
#     test_import( { type => 'series', number => 88, description => 'foo'  } );
# } "Title required on create.";

# dies_ok {
#     test_import( { id => 1, title => 'Renumbered collection', number => 23 },
#                  { id => 2, title => 'No number' } ) # number will be ''
# } "Number can't be empty on update";

# is( $schema->resultset( 'Collection' )->find( 1 )->number, 'n1',
#     'Number was not updated on failed import.' );

# dies_ok {
#     test_import( { type => 'collection',
#                    title => 'New collection', number => 123,
#                    documentation => 1 } )
# } "Collection processing status can't be missing on create.";

# dies_ok {
#     test_import( { type => 'collection',
#                    title => 'New collection', number => 123,
#                    processing_status => 1 } )
# } "Collection documentation can't be missing on create.";

# dies_ok {
#     test_import( { type => 'series',
#                    title => 'New unnumbered series', description => 'foo' } )
# } "Series number can't be missing on create.";

# dies_ok {
#     test_import( { type => 'item',
#                    title => 'New undated item', number => 123, dc_type => 1 } )
# } "Item start date can't be missing on create.";

# dies_ok {
#     test_import( { type => 'item',
#                    number => 55, title => 'foo', dc_type => 1,
#                    date_from => '1-1-2001' } )
# } 'Start date format must be ISO-8601 on create.';

# dies_ok {
#     test_import( { id => 1, date_from => '1-1-2001' } )
# } 'Start date format must be ISO-8601 on update.';

# dies_ok {
#     test_import( { id => 4, file_creation_date => '2001-1-32' } )
# } 'File creation date format must be ISO-8601.';

# dies_ok {
#     test_import( { id => 1, permanent_url => 'invalid:uri' } )
# } 'Permanent URL must be an http or https URI.';

# lives_ok {
#     test_import( { id => 1, permanent_url => 'https://example.com' } )
# } 'HTTPS permanent URL is ok.';

# lives_ok {
#     test_import( { id => 1, permanent_url => '' } )
# } 'Permanent URL can be unset.';

# TO DO:
# These should all be errors:
# nonexistent record_context or other foreign key (including location)
# hard-coded select fields out of range?
#
# check max lengths?
# test changing type

done_testing;
