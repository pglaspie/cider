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
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

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

my $item = $schema->resultset( 'Item' )->create( {
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
$set->add( $schema->resultset( 'Item' )->find( 5 ) );
$set->set_field( title => 'New Title' );

$hits = $model->search( query => 'Item' );
is( $hits->total_hits, 0, 'Found no Items.' );

$hits = $model->search( query => 'New Title' );
is( $hits->total_hits, 2, 'Found two New Titles.' );

my $importer = CIDER->model( 'Import' )->importer;
my $ischema = $importer->schema;
$ischema->user( $schema->resultset( 'User' )->find( 1 ) );

my $xml = <<END
<import>
  <create>
    <series number="1">
      <title>Imported series 1</title>
    </series>
    <series number="1"> <!-- duplicate number -->
      <title>Imported series 2</title>
    </series>
  </create>
</import>
END
;
open my $handle, '<', \$xml;
dies_ok( sub { $importer->import_from_xml( $handle ) }, 'Import fails.' );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 0, 'Found no Imported.' );

$xml = <<END
<import>
  <create>
    <series number="1">
      <title>Imported series 1</title>
    </series>
    <series number="2">
      <title>Imported series 2</title>
    </series>
  </create>
</import>
END
;
open $handle, '<', \$xml;
$importer->import_from_xml( $handle );

$hits = $model->search( query => 'Imported' );
is( $hits->total_hits, 2, 'Found two Imported.' );

# TO DO: should look for 'Minimal processing'
$hits = $model->search( query => 'minimal' );
is( $hits->total_hits, 2, 'Found two collections with processing status.' );

$query = KinoSearch::Search::TermQuery->new(
    field => 'corporate_names',
    term => 'name',
);
$hits = $model->search( query => $query );
is( $hits->total_hits, 0, 'No corporate names yet.' );

$item = $schema->resultset( 'Item' )->find( 4 );
my $name = $schema->resultset( 'AuthorityName' )->find( 1 );
$item->add_to_corporate_names( $name );
$item->update;

$hits = $model->search( query => $query );
is( $hits->total_hits, 1, 'Item was re-indexed with corporate name.' );

$name->name( 'Test Corp' );
$name->update;

$hits = $model->search( query => $query );
is( $hits->total_hits, 0, 'No hits for old corporate name.' );

$query = KinoSearch::Search::TermQuery->new(
    field => 'corporate_names',
    term => 'corp',
);
$hits = $model->search( query => $query );
is( $hits->total_hits, 1, 'Found new corporate name.' );

$hits = $model->search( query => 'Material' );
is( $hits->total_hits, 1, 'Found one collection with associated material.' );
my $coll = $schema->resultset( 'Collection' )->find( $hits->next->{ id } );

my $material = $coll->add_to_material( { material => 'Pamphlet' } );
$hits = $model->search( query => 'Pamphlet' );
is( $hits->total_hits, 1, 'Found added material.' );

$material->update( { material => 'Booklet' } );
$hits = $model->search( query => 'Booklet' );
is( $hits->total_hits, 1, 'Found updated material.' );

$material->delete;
$hits = $model->search( query => 'Booklet' );
is( $hits->total_hits, 0, 'Deleted material was deleted from the index.' );

done_testing();
