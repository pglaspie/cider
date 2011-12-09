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

is( $collection->date_from, '2000-01-01',
    'Earliest date_from is derived.' );
is( $collection->date_to, '2010-01-01',
    'Latest date_from is derived.' );

# TO DO: test missing date_to, missing day/month

is( $collection->accession_numbers, '2011.004;2011.005',
    'Accession numbers are derived.' );

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
  <bulkDate><from>2000</from><to>2001-01</to></bulkDate>
  <recordContexts>
    <primary>
      <recordContext>RCR00001</recordContext>
      <recordContext>RCR00002</recordContext>
    </primary>
    <secondary>
      <recordContext>RCR00002</recordContext>
    </secondary>
  </recordContexts>
  <documentation>no</documentation>
  <!-- Comments are ignored. -->
  <processingNotes>yadda <!-- even inside text --> yadda...</processingNotes>
  <associatedMaterial>
    <material>Pamphlet</material>
    <material>Brochure</material>
  </associatedMaterial>
  <languages>
    <language>eng</language>
    <language>ast</language>
  </languages>
  <permanentURL>http://example.com/</permanentURL>
  <relationships>
    <relationship predicate="rel:hasDescription">
      <pid>desc</pid>
    </relationship>
    <relationship predicate="fedora-model:hasModel">
      <pid>model</pid>
    </relationship>
  </relationships>
  <auditTrail>
    <create>
      <timestamp>1999-09-09</timestamp>
      <staff>
        <firstName>Collection</firstName>
        <lastName>Creator</lastName>
      </staff>
    </create>
    <update>
      <timestamp>2010-10-10T10:10:10-04:00</timestamp>
      <staff>
        <firstName>Alice</firstName>
        <lastName>Nelson</lastName>
      </staff>
    </update>
  </auditTrail>
</collection>
END
);

is( $collection->title, 'Renamed collection',
    'The modified collection has been renamed.');
is( $collection->bulk_date_from, '2000',
    'The collection bulk date from has been updated.' );
is( $collection->bulk_date_to, '2001-01',
    'The collection bulk date to has been updated.' );

is( $collection->primary_record_contexts, 2,
    'The modified collection has two primary record contexts.' );
is( ( $collection->primary_record_contexts )[0]->name_entry,
    'Context 1',
    'The first primary record context is correct.' );
is( ( $collection->primary_record_contexts )[1]->name_entry,
    'Context 2',
    'The second primary record context is correct.' );
is( $collection->secondary_record_contexts, 1,
    'The modified collection has one secondary record context.' );
is( ( $collection->secondary_record_contexts )[0]->name_entry,
    'Context 2',
    'The secondary record context is correct.' );

is( $collection->documentation, 'no',
    'The modified collection does not have physical documentation.');
is( $collection->processing_notes, 'yadda  yadda...',
    'The collection processing notes were modified.' );
is( $collection->notes, 'Test notes.  Unicode: « ☃ ° » yay.',
    'The modified collection has kept the same notes.');

is_deeply( [ $collection->material ], [ 'Pamphlet', 'Brochure' ],
           'The modified collection has new material.' );
my $cm_rs = $schema->resultset( 'CollectionMaterial' );
is( $cm_rs->count, 2,
    'Updating collection material deletes old material.' );

is_deeply( [ $collection->languages ], [ 'eng', 'ast' ],
           'The modified collection has new languages.' );

is( $collection->permanent_url, 'http://example.com/',
    'The collection permanent URL was modified.' );

is( $collection->collection_relationships, 2,
    'The modified collection has two relationships.' );
is( ( $collection->collection_relationships )[0]->predicate,
    'rel:hasDescription',
   'First relationship predicate is correct.' );
is( ( $collection->collection_relationships )[1]->pid,
    'model',
   'Second relationship pid is correct.' );

is( $collection->audit_trail->logs, 2,
    'Audit trail was imported.' );
is( $collection->audit_trail->creation_log->timestamp, '1999-09-09T00:00:00',
    'Creation timestamp is correct.' );
is( $collection->audit_trail->created_by, 'Creator, Collection',
    'Creator name is correct.' );
my $log = $collection->audit_trail->modification_logs->first;
is( $log->timestamp, '2010-10-10T14:10:10',
    'Modification timestamp is correct.' );
is( $log->staff->user->username, 'alice',
    'Modification user is correct.' );

$collection->update_from_xml( elt <<END
<collection>
  <bulkDate>2003</bulkDate>
  <associatedMaterial/>
  <notes/>
</collection>
END
);
is( $collection->bulk_date_from, '2003',
    'The collection bulk date from has been updated.' );
is( $collection->bulk_date_to, undef,
    'The collection bulk date to has been removed.' );
is( $collection->material, 0,
    'The associated material has been removed.' );
is( $collection->notes, undef,
    'The collection notes have been removed.');

$collection->update_from_xml( elt '<collection><bulkDate/></collection>' );
is( $collection->bulk_date_from, undef,
    'The collection bulk date from has been removed.' );
is( $collection->bulk_date_to, undef,
    'The collection bulk date to is still removed.' );

throws_ok {
    $collection->update_from_xml( elt <<END
<collection>
  <recordContexts>
    <primary>
      <recordContext>void</recordContext>
    </primary>
  </recordContexts>
</collection>
END
);
} qr/no record context/,
    'Record context not found.';

$collection->update_from_xml( elt '<collection><languages/></collection>' );
is_deeply( [ $collection->languages ], [ 'eng' ],
           'Default language is English.' );

$collection->delete;
is( $cm_rs->count, 0,
    'Deleting collection deletes associated material' );

done_testing;
