#!/usr/bin/perl

use warnings;
use strict;

use Test::More;
use Test::Exception;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

my $group = $schema->resultset( 'Item' )->create_from_xml( elt <<END
<item number='g1'>
  <title>test group item</title>
  <classes><group /></classes>
</item>
END
);

is( ( $group->groups )[0]->volume, 0,
    'Empty group volume is 0.' );

my $item = $schema->resultset( 'Object' )->find( { number => 'n4' } );
$item->parent( $group );
$item->update;
$item = $schema->resultset( 'Object' )->find( { number => 'n5' } );
$item->parent( $group );
$item->update;

is( $group->children, 2,
    'Group has two children.' );

is( ( $group->groups )[0]->volume, 2,
    'Group volume is 2.' );

done_testing;
