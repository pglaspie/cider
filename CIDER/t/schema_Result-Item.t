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
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

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
</item>
END
);
$rs->create_from_xml( elt <<END
<item number='x2' parent='n4'>
  <title>New sub-item</title>
  <date>2000</date>
</item>
END
);

my $item = $rs->find( 4 );
is( $item->number_of_children, 2,
    'After import create, ' . $item->title . ' has 2 children.' );
for my $subitem ( $item->children ) {
    is( $subitem->type, 'item', 'Type is correct.' );
    is( $subitem->title, 'New sub-item', 'Title is correct.' );
    ok( $subitem->number, 'Number exists.' );
    ok( !$subitem->circa, 'Circa is false.' );
    is( $subitem->date_from, '2000', 'Start date is correct.' );
    is( $subitem->date_to, undef, 'End date is undefined.' );
    is( $subitem->dc_type, 'Text', 'DC Type is correct.' );
}

$item->update_from_xml( elt <<END
<item>
  <creators>
    <creator>
      <name>George Washington</name>
      <note>First Prez</note>
    </creator>
  </creators>
  <corporateNames>
    <corporateName>
      <name>Context Co.</name>
    </corporateName>
  </corporateNames>
  <topicTerms>
    <topicTerm>
      <name>Bowling</name>
    </topicTerm>
    <topicTerm>
      <name>Sledding</name>
    </topicTerm>
  </topicTerms>
  <classes>
    <group/>
    <fileFolder>
      <location>11</location>
    </fileFolder>
    <container>
      <location>9001</location>
      <format>CookieJar</format>
    </container>
    <threeDimensionalObject>
      <location>8002</location>
      <format>CookieJar</format>
    </threeDimensionalObject>
    <threeDimensionalObject>
      <location>8002</location>
      <format>CookieJar</format>
    </threeDimensionalObject>
    <digitalObject>
      <location>12</location>
      <pid>xxx</pid>
      <stabilization>
        <by>
          <firstName>Alice</firstName>
          <lastName>Nelson</lastName>
        </by>
        <date>2010</date>
        <procedure>ACC-007</procedure>
      </stabilization>
      <applications>
        <mediaImage>GIMP</mediaImage>
        <other>
          <application>App1</application>
          <application>App2</application>
        </other>
      </applications>
    </digitalObject>
    <digitalObject>
      <location>12</location>
      <pid>xyz</pid>
      <stabilization>
        <by>
          <firstName>Bob</firstName>
          <lastName>Dobalina</lastName>
        </by>
      </stabilization>
      <applications>
        <mediaImage>GIMP</mediaImage>
      </applications>
    </digitalObject>
    <browsingObject>
      <relationships>
        <relationship predicate="rel:isSubsetOf">
          <pid>superset</pid>
        </relationship>
      </relationships>
    </browsingObject>
  </classes>
</item>
END
);

is( $item->creators, 1,
    'Item has one creator.' );
my $gw = $item->creators->first;
is( $gw->name, 'George Washington',
    'Creator name is correct.' );
is( $gw->note, 'First Prez',
    'Creator note is correct.' );
is( $item->corporate_names, 1,
    'Item has one corporate_name.' );
my $co = $item->corporate_names->first;
is( $co->name, 'Context Co.',
    'Corporate name is correct.' );
is( $co->note, undef,
    'Corporate name has no note.' );
is( $item->topic_terms, 2,
    'Item has two topic terms.' );
is( $item->classes, 8,
    'Item has eight classes.' );
is( $item->groups, 1,
    'Item has one group.' );
is( $item->file_folders->first->location->unit_type, 'Digital objects',
    'File folder location has digital objects unit type.' );
is( $item->file_folders->first->format, 'File (document grouping)',
    'File folder format is correct.' );
is( $item->containers->first->format, 'CookieJar',
    'Container format is correct.' );
is( $item->three_dimensional_objects->first->format, 'CookieJar',
    'Three dimensional object format is correct.' );
isnt( $item->containers->first->format->id,
      $item->three_dimensional_objects->first->format->id,
      'The container and 3d-object format authority terms are not the same.' );
my @tdos = $item->three_dimensional_objects;
is( $tdos[0]->format->id, $tdos[1]->format->id,
    'The 3d-object format authority terms are the same.' );
my @dos = $item->digital_objects;
is( $dos[0]->stabilized_by->user->username, 'alice',
    'First digital object stabilized by alice.' );
is( $dos[0]->stabilization_date, '2010',
    'First digital object stabilization date is correct.' );
is( $dos[0]->stabilization_procedure->name, 'Digital Media Stabilization',
    'First digital object stabilization procedure is correct.' );
is( $dos[0]->checksum_app, 'Advanced Checksum Verifier',
    'Digital object checksum app is correct.' );
is( $dos[0]->media_app, 'GIMP',
    'Digital object media image app is correct.' );
is_deeply( [ $dos[0]->other_apps ], [ 'App1', 'App2' ],
    'Digital object other apps are correct.' );
is( $dos[1]->stabilized_by->last_name, 'Dobalina',
    'Second digital object stabilized by a new staff.' );
is( $dos[0]->media_app->id, $dos[1]->media_app->id,
    'The digital object media image apps are the same.' );
is( $item->browsing_objects->first->browsing_object_relationships->first
        ->predicate, 'rel:isSubsetOf',
    'Browsing object relationship predicate is correct.' );

$item->update_from_xml( elt <<END
<item>
  <creators>
    <creator>
      <name>Context Co.</name>
      <note>Inc. 2011</note>
    </creator>
  </creators>
  <personalNames>
    <personalName>
      <name>George Washington</name>
      <note/>
    </personalName>
  </personalNames>
  <topicTerms/>
</item>
END
);

is( $item->creators, 1,
    'Item still has one creator.' );
is( $item->creators->first->id, $co->id,
    'Item creator was looked up.' );
$co->discard_changes;
is( $co->note, 'Inc. 2011',
    'Creator note was updated.' );
is( $item->personal_names, 1,
    'Item has one personal name.' );
is( $item->personal_names->first->id, $gw->id,
    'Item personal name was looked up.' );
$gw->discard_changes;
is( $gw->note, undef,
    'Personal name note was removed.' );
is( $item->topic_terms, 0,
    'Topic terms were removed.' );
is( $schema->resultset( 'ItemTopicTerm' ), 0,
    'Topic term links were deleted.' );
is( $schema->resultset( 'TopicTerm' ), 3,
    'Topic terms still exist.' );

$item->update_from_xml( elt '<item><circa>true</circa></item>' );
ok(  $item->circa, 'Circa "true" is true.' );
$item->update_from_xml( elt '<item><circa>1</circa></item>' );
ok(  $item->circa, 'Circa "1" is true.' );
$item->update_from_xml( elt '<item><circa>false</circa></item>' );
ok( !$item->circa, 'Circa "false" is false.' );
$item->update_from_xml( elt '<item><circa>0</circa></item>' );
ok( !$item->circa, 'Circa "0" is false.' );
$item->update_from_xml( elt '<item><circa/></item>' );
ok( !$item->circa, 'Circa empty is false.' );

$item->update_from_xml( elt '<item><dcType>Image</dcType></item>' );
is( $item->dc_type, 'Image',
    'DC type updated.' );
$item->update_from_xml( elt '<item><dcType/></item>' );
is( $item->dc_type, 'Text',
    'DC type set to default.' );

throws_ok {
    $item->update_from_xml( elt <<END
<item>
  <classes>
    <fileFolder>
      <location>nowhere</location>
    </fileFolder>
  </classes>
</item>
END
);
} qr/does not exist/,
    'Unknown location is an error.';

ok( $item->delete,
    'Item deleted.' );

done_testing;
