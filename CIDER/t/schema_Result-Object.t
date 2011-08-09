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
$schema->user( 1 );

use Test::More;
use Test::Exception;

my @collections = $schema->resultset('Object')->root_objects;

is (scalar @collections, 2, 'There are two collections.');

my $collection_1 = $collections[0];
is ($collection_1->title, 'Test Collection with kids',
    'Collection\'s name is correct.'
);
isa_ok ($collection_1, 'CIDER::Schema::Result::Collection',
     'Collection'
 );
is( $collection_1->type, 'collection', 'type is collection.' );


my @series = $collection_1->children;
is (scalar @series, 1, 'There is one child series.');

my $series_1 = $series[0];
is ( $series_1->title, 'Test Series 1',
     "The series' name is correct."
 );
isa_ok ($series_1, 'CIDER::Schema::Result::Series',
     'Series'
 );
is( $series_1->type, 'series', 'type is series.' );

my @items = $series_1->children;
is (scalar @items, 2, 'There are two child item.');

my ( $item_1, $item_2 ) = @items;

is ( $item_1->title, 'Test Item 1',
     "The item's name is correct."
 );
isa_ok ($item_1, 'CIDER::Schema::Result::Item',
     'Item'
 );
is( $item_1->type, 'item', 'type is item.' );

is ( $item_1->parent->id, $series_1->id,
     "The series is the parent of the item."
 );

# TO DO: re-implement date ranges on collections and series.

# is( $collection_1->date_from, $item_1->date_from,
#     "The collection's date_from is the earliest date_from of its subitems.");

# is( $collection_1->date_to, $item_2->date_to,
#     "The collection's date_to is the latest date_to of its subitems.");

my $collection_2 = $collections[1];

is ($series_1->has_ancestor( $collection_2 ), 0,
    'Before moving, the series does not see the collection as ancestor.' );

$series_1->parent( $collection_2 );
$series_1->update;

is (scalar($collection_2->children), 1,
    'After moving, there is one child series in the second collection.');
is (scalar($collection_1->children), 0,
    'After moving, there are no child series in the first collection.');
is ($series_1->has_ancestor( $collection_2 ), 1,
    'After moving, the series claims the collection as ancestor.' );

throws_ok { $collection_2->parent( $series_1 ) } qr/ancestor/,
    "The series refuses to become its ancestor's parent.";

throws_ok { $collection_2->parent( $collection_2 ) } qr/its own/,
    "The series refuses to become its own parent.";

my $elt = elt <<END
<foo>
  <bar>Blah</bar>
  <!-- Comment is ignored. -->
  <baz>
    <garply />
  </baz>
</foo>
END
;
is_deeply( DBIx::Class::UpdateFromXML->xml_to_hashref( $elt ), {
    bar => 'Blah',
    baz => [ $elt->getElementsByTagName( 'garply' ) ],
}, 'xml_to_hashref works' );

my $rs = $schema->resultset( 'Series' );

my $series_2 = $rs->create_from_xml( elt <<END
<series number='s2' parent='n3'>
  <title>New sub-series</title>
</series>
END
);

isa_ok( $series_2, 'CIDER::Schema::Result::Series',
        'Imported series' );

is( $series_1->number_of_children, 3,
    'After import create, ' . $series_1->title . ' has 3 children.' );

$series_2->update_from_xml( elt <<END
<series parent="n1">
  <title>Updated sub-series</title>
</series>
END
);

is( $collection_1->number_of_children, 1,
    'After import update, ' . $collection_1->title . ' has 1 child.' );
is( $series_2->title, 'Updated sub-series',
    'Import update changed the title.' );

$series_2->update_from_xml( elt '<series parent="" />' );

is( scalar $schema->resultset( 'Object' )->root_objects, 3,
    'After import update, there are 3 root objects.' );

throws_ok {
    $series_2->update_from_xml( elt '<series parent="foo" />' );
} qr/does not exist/,
    'Import updating parent to nonexistent parent is an error.';

done_testing;
