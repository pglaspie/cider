#!/usr/bin/perl

# Tests of basic CIDER objects.

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

my @collections = $schema->resultset('Object')->root_objects;

is (scalar @collections, 2, 'There are two collections.');

my $collection_1 = $collections[0];
is ($collection_1->title, 'Test Collection with kids',
    'Collection\'s name is correct.'
);
isa_ok ($collection_1, 'CIDER::Schema::Result::Collection',
     'Collection'
 );

my @series = $collection_1->children;
is (scalar @series, 1, 'There is one child series.');

my $series_1 = $series[0];
is ( $series_1->title, 'Test Series 1',
     "The series' name is correct."
 );
isa_ok ($series_1, 'CIDER::Schema::Result::Series',
     'Series'
 );

my @items = $series_1->children;
is (scalar @items, 2, 'There are two child item.');

my $item_1 = $items[0];
is ( $item_1->title, 'Test Item 1',
     "The item's name is correct."
 );
isa_ok ($item_1, 'CIDER::Schema::Result::Item',
     'Item'
 );

is ( $item_1->parent->id, $series_1->id,
     "The series is the parent of the item."
 );

my $collection_2 = $collections[1];
$series_1->parent( $collection_2 );
$series_1->update;

is (scalar($collection_2->children), 1,
    'After moving, there is one child series in the second collection.');
is (scalar($collection_1->children), 0,
    'After moving, there are no child series in the first collection.');

