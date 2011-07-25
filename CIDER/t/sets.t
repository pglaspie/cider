#!/usr/bin/perl

# Tests of CIDER set objects.

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

my $user = $schema->resultset( 'User' )->find( 1 );
$schema->user( $user );

my @sets = $user->sets;
is ( scalar @sets, 2, 'User has two sets.');

my $item = $schema->resultset( 'Object' )->find( 5 );
my $series = $schema->resultset( 'Object' )->find( 3 );
my $homog_set = $sets[0];
my $heterog_set = $sets[1];

is (scalar( $homog_set->objects ), 1,
    'Before adding an item, the homogenous set contains one object.'
);

$homog_set->add( $item );
is (scalar( $homog_set->objects ), 2,
    'After adding an item, the homogenous set contains two objects.'
);

is (scalar( $heterog_set->objects ), 1,
    'Before adding an item, the heterogenous set contains one object.'
);

$heterog_set->add( $series );
is (scalar( $heterog_set->objects ), 2,
    'After adding an item, the heterogenous set contains two objects.'
);

is ( $homog_set->is_homogenous, 1,
     'The homogenous set reports as homogenous.'
 );

is ( $heterog_set->is_homogenous, 0,
     'The heterogenous set reports as not homogenous.'
 );

$heterog_set->remove( $series );
is (scalar( $heterog_set->objects ), 1,
    'After removing an item, the heterogenous set contains one object.'
);


$homog_set->search_and_replace( { field => 'title',
                                  old   => 'Test',
                                  new   => 'Good',
                              } );
for my $item ( $homog_set->objects ) {
    like ( $item->title, qr/^Good Item/,
           "Item's title successfully changed."
       );
}

my $collection = $schema->resultset( 'Object' )->find( 2 );
$homog_set->move_all_objects_to( $collection );
for my $item ( $homog_set->objects ) {
    is ( $item->parent->id, 2,
           "Item successfully moved."
       );
}

$homog_set->set_field( title => 'New Title' );
for my $item ( $homog_set->objects ) {
    is ( $item->title, 'New Title',
           "Item's title successfully changed."
       );
}

my $id = $homog_set->id;
my @items = $homog_set->objects;
ok( $homog_set->delete, 'Deleted the homogenous set.' );
is( scalar $user->sets, 1, 'User has one set.');
for my $item ( @items ) {
    ok( $item->in_storage, 'Item ' . $item->id . ' still exists.' );
}
my $rs = $schema->resultset( 'ObjectSetObject' )->search( {
    object_set => $id
} );
is( $rs->count, 0, 'Relations were deleted.' );
