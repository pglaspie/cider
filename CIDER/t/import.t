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

use Test::More qw(no_plan);
use Test::Exception;

use CIDER::Logic::Importer;
use FindBin;
use Text::CSV::Slurp;

my $db_dir   = "$FindBin::Bin/db";
my $db_file  = "$db_dir/cider.db";

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
    date_from => '2000-01-01',
} );

test_import( {
    title => 'Brand-new collection',
    record_context => 1,
    date_from => '2000-01-01',
    number    => 41,
    language  => 'eng',
    has_physical_documentation => 1,
} );

test_import( {
    parent => 4,
    title => 'New sub-item',
    number => 99,
    type => 1,
} );

@collections = $schema->resultset('Object')->root_objects;
is ( scalar @collections, 3,
     "After import, there are three root objects." );
is ( $collections[1]->title, 'Renamed collection',
     "After import, the modified collection has been renamed.");
is ( $collections[1]->date_from, '2000-01-01',
     "After import, the modified collection has kept the same date.");
is ( $collections[1]->notes, 'Test notes.',
     "After import, the modified collection has kept the same notes.");
is ( $collections[2]->title, 'Test Collection without kids',
     "After import, the untouched collection has the expected name.");
is ( $collections[0]->title, 'Brand-new collection',
     "After import, the new collection has the expected name.");

my $item = $schema->resultset( 'Object' )->find( 4 );
is( $item->number_of_children, 1,
    'After import, ' . $item->title . ' has 1 child.' );
my $subitem = ( $item->children )[0];
is( $subitem->title, 'New sub-item', 'Title is correct.' );
is( $subitem->number, 99, 'Number is correct.' );
is( $subitem->type->name, 'Test Type', 'Type is correct.' );

dies_ok {
    test_import( { number => 88 } );
} "Title required on create.";

dies_ok {
    test_import( { id => 1, title => 'Renumbered collection', number => 23 },
                 { id => 2, title => 'No number' } ) # number will be ''
} "Number can't be empty on update";

is( $schema->resultset( 'Object' )->find( 1 )->number, 12345,
    'Number was not updated on failed import.' );

dies_ok {
    test_import( { title => 'New unnumbered collection' } )
} "Number can't be missing on create.";

# dies_ok {
#     test_import( { id => 1, date_from => '1-1-2001' } )
# } 'Date format must be ISO-8601.';

# dies_ok {
#     test_import( { id => 1, permanent_url => 'invalid:uri' } )
# } 'Permanent URL must be an http or https URI.';

# TO DO:
# These should all be errors:
# date_from missing
# series: accession_number, description missing
# collection: has_physical_documentation missing (or default to no?)
# nonexistent record_context or other foreign key (including location)
# hard-coded select fields out of range?
# nonexistent parent
#
# check max lengths?
# test cider_type
