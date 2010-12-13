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

use CIDER::Importer;
use FindBin;
use Text::CSV::Slurp;

my $db_dir   = "$FindBin::Bin/db";
my $db_file  = "$db_dir/cider.db";

my $importer = CIDER::Importer->new (
    {
        schema_class => 'CIDER::Schema',
        connect_info => [ "dbi:SQLite:$db_file", '', '', ],
    }
);

isa_ok ($importer, 'CIDER::Importer');

# Use Text::CSV::Slurp to quickly-but-accurately whip up a simple test CSV.
# Then stuff it into a filehandle for CIDER::Importer to chew on.
my $data = [
    {
        id => 1,
        title => 'Renamed collection',
        record_creator => 1,
        date_from => '2000-01-01',
        date_to   => '2010-01-01',
        number    => 1,
    },
    {
        title => 'Brand-new collection',
        record_creator => 1,
        date_from => '2000-01-01',
        date_to   => '2010-01-01',
        number    => 41,
    }
];

my $csv = Text::CSV::Slurp->create( input => $data );
open my $handle, '<', \$csv;

my @collections = $schema->resultset('Object')->root_objects;
is ( scalar @collections, 2,
     "Before import, there are two root objects." );
is ( $collections[0]->title, 'Test Collection with kids',
    "Before import, the collection we want to modify has the expected name.");

$importer->import_from_csv( $handle );

@collections = $schema->resultset('Object')->root_objects;
is ( scalar @collections, 3,
     "After import, there are three root objects." );
is ( $collections[1]->title, 'Renamed collection',
     "After import, the modified collection has been renamed.");
is ( $collections[2]->title, 'Test Collection without kids',
     "After import, the untouched collection has the expected name.");
is ( $collections[0]->title, 'Brand-new collection',
     "After import, the new collection has the expected name.");
