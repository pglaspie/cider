#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use DateTime;

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

use Test::More;
use Test::Exception;

my $rs = $schema->resultset( 'RecordContext' );
my $rc = $rs->find( 1 );
is( $rc->name_entry, 'Context 1',
    'Context 1 name_entry is correct.' );
is( $rc->rc_type, 'corporateBody',
    'Context 1 rc_type is correct.' );

$rs->create( {
    record_id => 'RCR00023',
    name_entry => 'Context 23',
    ongoing => 1,
} );

ok( $rc = $rs->find( { record_id => 'RCR00023' } ),
    'Context 23 was created.' );
is( $rc->name_entry, 'Context 23',
    'name_entry is correct.' );
is( $rc->rc_type, 'corporateBody',
    'rc_type is correct.' );
ok( !$rc->circa,
    'circa is correct.' );
ok( $rc->ongoing,
    'ongoing is correct.' );

my $trail = $rc->audit_trail;
is( $trail->created_by->user->id, 1,
    'Context 23 created by user 1.' );
is( $trail->date_created, DateTime->today,
    'Creation date is today.' );

$rc->update( { name_entry => 'Updated context' } );
my $logs = $trail->modification_logs;
is( $logs->count, 1, 'Modified once.' );
is( $logs->first->user->id, 1, 'Modified by user 1.' );

$rc->export;
is( $trail->date_available, DateTime->today, 'Date available is today.' );

$rc->update_from_xml( elt <<END
<recordContext>
  <nameEntry>Updated context</nameEntry>
  <publicationStatus>draft</publicationStatus>
  <rcType>person</rcType>
  <alternateNames>
    <name>Name1</name>
    <name>Name2</name>
  </alternateNames>
  <date><from>2006</from><to>2008</to></date>
  <circa>true</circa>
  <ongoing/>
  <function>Function</function>
  <occupations>
    <occupation>
      <titles>
        <title>Vice-President</title>
        <title>President Pro Tem</title>
      </titles>
      <date>1787</date>
    </occupation>
  </occupations>
  <relationships>
    <relationship type="reportsTo">
      <relatedEntity>RCR00001</relatedEntity>
      <date>1900</date>
    </relationship>
  </relationships>
</recordContext>
END
);

is( $rc->publication_status, 'draft',
    'publication_status was updated.' );
is( $rc->name_entry, 'Updated context',
    'name_entry was updated.' );
is( $rc->rc_type, 'person',
    'rc_type was updated.' );
is_deeply( [ $rc->alt_names ], [ 'Name1', 'Name2' ],
           'alt_names was updated.' );
is( $rc->date_from, '2006',
    'date_from was updated.' );
is( $rc->date_to, '2008',
    'date_to was updated.' );
ok( $rc->circa,
    'circa was updated.' );
ok( !$rc->ongoing,
    'ongoing was updated.' );
is( $rc->function, 'Function',
    'function was updated.' );
my $occ = $rc->occupations->first;
is_deeply( [ $occ->titles ], [ 'Vice-President', 'President Pro Tem' ],
           'Occupation titles are correct.' );
is( $occ->date_from, '1787',
    'Occupation date is correct.' );
my $rel = $rc->record_context_relationships->first;
is( $rel->type, 'reportsTo',
    'Relationship type is correct.' );
is( $rel->related_entity->name_entry, 'Context 1',
    'Related entity is correct.' );
is( $rel->date_from, '1900',
    'Relationship start date is correct.' );

# TO DO: audit trail

throws_ok {
    $rc->update_from_xml( elt <<END
<recordContext>
  <relationships>
    <relationship type="reportsTo">
      <relatedEntity>XYZ</relatedEntity>
    </relationship>
  </relationships>
</recordContext>
END
);
} qr/does not exist/,
    'Non-existent relatedEntity is an error.';

$rc->delete;
is( $schema->resultset( 'AuditTrail' )->find( $trail->id ), undef,
    'Audit trail was deleted.' );

$rc = $rs->create_from_xml( elt <<END
<recordContext recordID="new">
  <nameEntry>New Context</nameEntry>
  <auditTrail>
    <create>
      <timestamp>2000</timestamp>
      <staff><firstName>X</firstName><lastName>Y</lastName></staff>
    </create>
  </auditTrail>
</recordContext>
END
);

is( $rc->audit_trail->logs, 1,
    'Audit trail imported on create.' );
is( $rc->audit_trail->created_by, 'Y, X',
    'Creator name is correct.' );
is( $rc->audit_trail->date_created, '2000-01-01T00:00:00',
    'Creation date is correct.' );

done_testing;
