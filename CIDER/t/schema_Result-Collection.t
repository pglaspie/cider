#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use Test::More;
use Test::Exception;

# See:  http://www.effectiveperlprogramming.com/blog/1226
if ( Test::Builder->VERSION < 2 ) {
    foreach my $method ( qw(output failure_output) ) {
        binmode Test::More->builder->$method, ':encoding(UTF-8)';
    }
}

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

my $collection = $schema->resultset( 'Collection' )->find( 1 );

is( $collection->languages->first->language_name, 'English',
    'The collection language is English.' );

is( $collection->notes, 'Test notes.  Unicode: « ☃ ° » yay.',
    'Unicode is working.' );

my $material = $collection->add_to_material( {
    material => 'Test Material 3'
} );
is( $collection->material->count, 3,
    'Has 3 associated materials after adding' );
$material->delete;
is( $collection->material->count, 2,
    'Has 2 associated materials after deleting' );
is( $collection->material->first, 'Test Material 1',
    'First associated material is correct' );

$collection->update_from_xml( elt <<END
<collection>
  <title>Renamed collection</title>
  <documentation>no</documentation>
  <associatedMaterial>
    <material>Pamphlet</material>
    <material>Brochure</material>
  </associatedMaterial>
  <languages>
    <language>eng</language>
    <language>ast</language>
  </languages>
</collection>
END
);

# TO DO: other fields

is( $collection->title, 'Renamed collection',
    'The modified collection has been renamed.');
is( $collection->documentation, 'no',
    'The modified collection does not have physical documentation.');
is( $collection->notes, 'Test notes.  Unicode: « ☃ ° » yay.',
    'The modified collection has kept the same notes.');

# TO DO: it shouldn't alphabetize these!
# is_deeply( [ $collection->languages ], [ 'eng', 'ast' ]
is_deeply( [ $collection->languages ], [ 'ast', 'eng' ],
           'The modified collection has new languages.' );

is_deeply( [ $collection->material ], [ 'Pamphlet', 'Brochure' ],
           'The modified collection has new material.' );

my $cm_rs = $schema->resultset( 'CollectionMaterial' );
is( $cm_rs->count, 2,
    'Updating collection material deletes old material.' );

$collection->delete;
is( $cm_rs->count, 0,
    'Deleting collection deletes associated material' );

done_testing;
