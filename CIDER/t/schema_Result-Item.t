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
$schema->user( 1 );

use Test::More;
use Test::Exception;

my $rs = $schema->resultset( 'Item' );

my ( $item_1, $item_2 ) = $rs->all;

is( $item_1->date_from, '2000-01-01',
    "Item 1's date_from is correct." );

is( $item_2->date_to, '2010-01-01',
    "Item 2's date_to is correct." );

$item_2->date_to( '2011-01' );
$item_2->update;

is( $rs->find( $item_2->id )->date_to,
    '2011-01',
    "Item 2's new date_to is correct." );

$rs->create_from_xml( elt <<END
<item number='x1' parent='n4'>
  <title>New sub-item</title>
  <date>2000</date>
  <dcType>Text</dcType>
</item>
END
);
$rs->create_from_xml( elt <<END
<item number='x2' parent='n4'>
  <title>New sub-item</title>
  <date>2000</date>
  <dcType>Text</dcType>
</item>
END
);
# TO DO: dcType should default to Text

my $item = $rs->find( 4 );
is( $item->number_of_children, 2,
    'After import create, ' . $item->title . ' has 2 children.' );
for my $subitem ( $item->children ) {
    is( $subitem->type, 'item', 'Type is correct.' );
    is( $subitem->title, 'New sub-item', 'Title is correct.' );
    ok( $subitem->number, 'Number exists.' );
    is( $subitem->date_from, '2000', 'Start date is correct.' );
    is( $subitem->dc_type, 'Text', 'DC Type is correct.' );
}

done_testing;
