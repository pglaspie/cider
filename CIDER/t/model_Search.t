use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'CIDER::Model::Search' }

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;

use Text::CSV::Slurp;

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
    date_from => '2000',
    dc_type => 1,
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

my $set = $schema->resultset( 'ObjectSet' )->find( 1 );
$set->add( $schema->resultset( 'Object' )->find( 5 ) );
$set->set_field( title => 'New Title' );

$hits = $model->search( query => 'Item' );
is( $hits->total_hits, 0, 'Found no Items.' );

$hits = $model->search( query => 'New Title' );
is( $hits->total_hits, 2, 'Found two New Titles.' );

my $importer = CIDER->model( 'Import' )->importer;
my $csv = Text::CSV::Slurp->create( input => [ {
    title => 'Imported series 1',
    number => 1,
    description => 'foo',
}, {
    title => 'Imported series 2',
    description => 'foo',
    # error - no number
} ] );
open my $handle, '<', \$csv;
dies_ok( sub { $importer->import_from_csv( $handle ) }, 'Import fails.' );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 0, 'Found no Imported.' );

$csv = Text::CSV::Slurp->create( input => [ {
    title => 'Imported series 1',
    number => 1,
    description => 'foo',
}, {
    title => 'Imported series 2',
    number => 2,
    description => 'foo',
} ] );
open $handle, '<', \$csv;
$importer->import_from_csv( $handle );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 2, 'Found two Imported.' );

$hits = $model->search( query => 'Status' );
is( $hits->total_hits, 2, 'Found two collections with processing status.' );

$query = KinoSearch::Search::TermQuery->new(
    field => 'corporate_name',
    term => 'name',
);
$hits = $model->search( query => $query );
is( $hits->total_hits, 0, 'No corporate names yet.' );

$item = $schema->resultset( 'Object' )->find( 4 );
$item->corporate_name( 1 );
$item->update;

$hits = $model->search( query => $query );
is( $hits->total_hits, 1, 'Item was re-indexed with corporate name.' );

my $name = $schema->resultset( 'AuthorityName' )->find( 1 );
$name->name( 'Test Corp' );
$name->update;

$hits = $model->search( query => $query );
is( $hits->total_hits, 0, 'No hits for old corporate name.' );

$query = KinoSearch::Search::TermQuery->new(
    field => 'corporate_name',
    term => 'corp',
);
$hits = $model->search( query => $query );
is( $hits->total_hits, 1, 'Found new corporate name.' );

$hits = $model->search( query => 'Material' );
is( $hits->total_hits, 1, 'Found one collection with associated material.' );
my $collection = $schema->resultset( 'Object' )->find( $hits->next->{ id } );

my $material = $collection->add_to_material( { material => 'Pamphlet' } );
$hits = $model->search( query => 'Pamphlet' );
is( $hits->total_hits, 1, 'Found added material.' );

$material->update( { material => 'Booklet' } );
$hits = $model->search( query => 'Booklet' );
is( $hits->total_hits, 1, 'Found updated material.' );

$material->delete;
$hits = $model->search( query => 'Booklet' );
is( $hits->total_hits, 0, 'Deleted material was deleted from the index.' );

done_testing();
