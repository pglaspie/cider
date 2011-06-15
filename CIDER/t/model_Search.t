use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'CIDER::Model::Search' }

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
CIDERTest->init_index( $schema );

use CIDER;
my $model = CIDER->model( 'Search' );
my $searcher = $model->searcher;
my $hits = $searcher->hits( query => 'Item' );
is( $hits->total_hits, 2, 'Found two Items.' );
is( $hits->next->{title}, 'Test Item 1', 'Found Test Item 1.' );
is( $hits->next->{title}, 'Test Item 2', 'Found Test Item 2.' );

my $item = $schema->resultset( 'Object' )->create( {
    number => 3,
    title => 'Test Item 3',
    type => 1,
} );
ok( $item, 'Created Item 3.' );

my $item_rs = $schema->resultset( 'Object' )->search_rs( { number => 3 } );
is( $item_rs->count, 1, 'About to index Item 3.' );

my $indexer = $model->indexer;
$indexer->add( $item_rs );

$searcher = $model->searcher;
$hits = $searcher->hits( query => 'Item' );
is( $hits->total_hits, 3, 'Found three Items.' );
is( $hits->next->{title}, 'Test Item 3', 'Found Test Item 3.' );

done_testing();
