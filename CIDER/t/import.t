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

use Test::More qw(no_plan);
use Test::Exception;

use CIDER::Logic::Importer;
use FindBin;
use Text::CSV::Slurp;

my $importer = CIDER::Logic::Importer->new( schema => $schema );

isa_ok ($importer, 'CIDER::Logic::Importer');

# Use Text::CSV::Slurp to quickly-but-accurately whip up a simple test CSV.
# Then stuff it into a filehandle for CIDER::Logic::Importer to chew on.

sub test_import {
    my $csv = Text::CSV::Slurp->create( input => [ @_ ] );
    open my $handle, '<', \$csv;
    $importer->import_from_csv( $handle );
}

my @collections = $schema->resultset('Object')->root_objects;
is ( scalar @collections, 2,
     "Before import, there are two root objects." );
is ( $collections[0]->title, 'Test Collection with kids',
    "Before import, the collection we want to modify has the expected name.");

test_import( {
    id => 1,
    title => 'Renamed collection',
} );

test_import( {
    type => 'collection',
    title => 'Brand-new collection',
    record_context => 1,
    number    => 41,
    language  => 'eng',
    has_physical_documentation => 0,
    processing_status => 1,
} );

test_import( {
    parent => 'n4',
    type => 'item',
    title => 'New sub-item',
    number => 'x1',
    date_from => '2000',
    dc_type => 1,
}, {
    parent => 'n4',
    type => 'item',
    title => 'New sub-item',
    number => 'x2',
    date_from => '2000',
    dc_type => 1,
} );

@collections = $schema->resultset('Object')->root_objects;
is ( scalar @collections, 3,
     "After import, there are three root objects." );
is ( $collections[1]->title, 'Renamed collection',
     "After import, the modified collection has been renamed.");
is ( $collections[1]->notes, 'Test notes.',
     "After import, the modified collection has kept the same notes.");
is ( $collections[2]->title, 'Test Collection without kids',
     "After import, the untouched collection has the expected name.");
is ( $collections[0]->title, 'Brand-new collection',
     "After import, the new collection has the expected name.");

my $item = $schema->resultset( 'Item' )->find( 4 );
is( $item->number_of_children, 2,
    'After import, ' . $item->title . ' has 2 children.' );
for my $subitem ( $item->children ) {
    is( $subitem->type, 'item', 'Type is correct.' );
    is( $subitem->title, 'New sub-item', 'Title is correct.' );
    ok( $subitem->number, 'Number exists.' );
    is( $subitem->date_from, '2000', 'Start date is correct.' );
    is( $subitem->dc_type, 'Test Type', 'DC Type is correct.' );
}

dies_ok {
    test_import( { type => 'series', number => 88, description => 'foo'  } );
} "Title required on create.";

dies_ok {
    test_import( { id => 1, title => 'Renumbered collection', number => 23 },
                 { id => 2, title => 'No number' } ) # number will be ''
} "Number can't be empty on update";

is( $schema->resultset( 'Collection' )->find( 1 )->number, 'n1',
    'Number was not updated on failed import.' );

dies_ok {
    test_import( { title => 'New collection', number => 123,
                   type => 'collection',
                   record_context => 1, has_physical_documentation => 1 } )
} "Collection processing status can't be missing on create.";

dies_ok {
    test_import( { title => 'New collection', number => 123,
                   type => 'collection',
                   record_context => 1, processing_status => 1 } )
} "Collection has_physical_documentation can't be missing on create.";

dies_ok {
    test_import( { type => 'series',
                   title => 'New unnumbered series', description => 'foo' } )
} "Series number can't be missing on create.";

dies_ok {
    test_import( { type => 'series',
                   title => 'New undescribed series', number => 28 } )
} "Series description can't be missing on create.";

dies_ok {
    test_import( { type => 'item',
                   title => 'New undated item', number => 123, dc_type => 1 } )
} "Item start date can't be missing on create.";

dies_ok {
    test_import( { number => 55, title => 'foo', dc_type => 1,
                   type => 'item',
                   date_from => '1-1-2001' } )
} 'Start date format must be ISO-8601 on create.';

dies_ok {
    test_import( { id => 1, date_from => '1-1-2001' } )
} 'Start date format must be ISO-8601 on update.';

dies_ok {
    test_import( { id => 4, file_creation_date => '2001-1-32' } )
} 'File creation date format must be ISO-8601.';

dies_ok {
    test_import( { id => 1, permanent_url => 'invalid:uri' } )
} 'Permanent URL must be an http or https URI.';

lives_ok {
    test_import( { id => 1, permanent_url => 'https://example.com' } )
} 'HTTPS permanent URL is ok.';

lives_ok {
    test_import( { id => 1, permanent_url => '' } )
} 'Permanent URL can be unset.';

throws_ok {
    test_import( { id => 5, parent => 4 } )
} qr(parent), 'Unknown parent number is an error.';

# TO DO:
# These should all be errors:
# nonexistent record_context or other foreign key (including location)
# hard-coded select fields out of range?
# nonexistent parent
#
# check max lengths?
# test missing type, invalid type, changing type
