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
}, {
    title => 'Imported series 2',
    # error - no number
} ] );
open my $handle, '<', \$csv;
dies_ok( sub { $importer->import_from_csv( $handle ) }, 'Import fails.' );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 0, 'Found no Imported.' );

$csv = Text::CSV::Slurp->create( input => [ {
    title => 'Imported series 1',
    number => 1,
}, {
    title => 'Imported series 2',
    number => 2,
} ] );
open $handle, '<', \$csv;
$importer->import_from_csv( $handle );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 2, 'Found two Imported.' );

done_testing();
