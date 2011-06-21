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

use CIDER;
my $model = CIDER->model( 'Search' );
my $query = KinoSearch::Search::TermQuery->new(
    field => 'title',
    term => 'item',
);
my $hits = $model->search( query => $query );
is( $hits->total_hits, 2, 'Found two Items.' );
is( $hits->next->{title}, 'Test Item 1', 'Found Test Item 1.' );
is( $hits->next->{title}, 'Test Item 2', 'Found Test Item 2.' );

my $item = $schema->resultset( 'Object' )->create( {
    number => 3,
    title => 'Test Item 3',
    type => 1,
} );
ok( $item, 'Created Item 3.' );

$hits = $model->search( query => 'Item' );
is( $hits->total_hits, 3, 'Found three Items.' );
is( $hits->next->{title}, 'Test Item 3', 'Found Test Item 3.' );

$item->title( 'Test Object 3' );
$item->update;

$hits = $model->search( query => 'Item' );
is( $hits->total_hits, 2, 'Found two Items.' );
is( $hits->next->{title}, 'Test Item 1', 'Found Test Item 1.' );
is( $hits->next->{title}, 'Test Item 2', 'Found Test Item 2.' );

$hits = $model->search( query => 'Object' );
is( $hits->total_hits, 1, 'Found one Object.' );
is( $hits->next->{title}, 'Test Object 3', 'Found Test Object 3.' );

$item->delete;

$hits = $model->search( query => 'Object' );
is( $hits->total_hits, 0, 'Found no Objects.' );

done_testing();
