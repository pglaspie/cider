package CIDERTest;
use strict;
use warnings;
use Carp qw( cluck );

$SIG{ __WARN__ } = sub { cluck shift };

use base qw( Exporter );
our @EXPORT    = qw( elt );
our @EXPORT_OK = qw( elt );

use FindBin;

$ENV{CIDER_SITE_CONFIG} = "$FindBin::Bin/conf/cider.conf";
#$ENV{CIDER_DEBUG}       = 0;

use utf8;
use Carp qw(croak);
use English;
use File::Path qw(make_path remove_tree);

use CIDER::Schema;
use CIDER::Logic::Indexer;

# TO DO: get these from the config file?
my $db_dir    = "$FindBin::Bin/db";
my $db_file   = "$db_dir/cider.db";
my $dsn       = "dbi:SQLite:$db_file";
my $index_dir = "$FindBin::Bin/db/index";

sub init_schema {
    my $self = shift;
    my %args = @_;

    if (-e $db_file) {
        unlink $db_file
            or croak("Couldn't unlink $db_file: $OS_ERROR");
    }

    my $schema = CIDER::Schema->
        connect( $dsn, '', '', {
            sqlite_unicode => 1,
            on_connect_call => 'use_foreign_keys',
        });

    # Create the index directory if it doesn't already exist.
    make_path( $index_dir );

    $schema->search_index( $index_dir );

    # The default dir for deploy is "./", which means that if you run
    # the tests from CIDER_HOME it tries to read cider.sql to get the
    # deployment statements rather than generating them for SQLite.
    # So we have to specify the dir here, even though it actually uses
    # the path in the $dsn to write the SQLite file...
    $schema->deploy( undef, $db_dir );

    $schema->populate(
        'AuditTrail',
        [
            [qw/id/],
            [1],
            [2],
            [3],
            [4],
            [5],
            [6],
            [7],
        ]
    );

    $schema->populate(
        'RecordContextType',
        [
            [qw/id name/],
            [1, 'corporateBody'],
            [2, 'family'],
            [3, 'person'],
        ]
    );

    $schema->populate(
        'RecordContext',
        [
            [qw/id record_id name_entry rc_type date_from history audit_trail/],
            [1, 'RCR00001', 'Context 1', 1, '1900', 'History 1', 6],
            [2, 'RCR00002', 'Context 2', 1, '2000', 'History 2', 7],
        ]
    );

    $schema->populate(
        'RecordContextSource',
        [
            [qw/record_context source/],
            [1, 'Source 1'],
            [2, 'Source 2'],
        ]
    );

    $schema->populate(
        'Staff',
        [
            [qw/id first_name last_name/],
            [1, 'Alice', 'Nelson'],
        ]
    );

    $schema->populate(
        'User',
        [
            [qw/id username password staff/],
            [1, 'alice', 'foo', 1],
        ]
    );

    $schema->populate(
        'ObjectSet',
        [
            [qw/id name owner/],
            [1, 'Test Set 1', 1],
            [2, 'Test Set 2', 1],
        ]
    );

    $schema->populate(
        'Documentation',
        [
            [qw/id name description/],
            [1, 'yes', 'Has physical documentation'],
            [2, 'no', 'Does not have physical documentation'],
        ]
    );

    $schema->populate(
        'ProcessingStatus',
        [
            [qw/id name description/],
            [1, 'minimal', 'Minimal processing'],
        ]
    );

    $schema->populate(
        'PublicationStatus',
        [
            [qw/id name/],
            [1, 'draft'],
        ]
    );

    $schema->populate(
        'DCType',
        [
            [qw/id name/],
            [1, 'Text'],
            [2, 'Image'],
        ]
    );

    $schema->populate(
        'RelationshipPredicate',
        [
            [qw/id predicate/],
            [1, 'fedora-model:hasModel'],
            [2, 'rel:hasDescription'],
            [3, 'rel:isSubsetOf'],
        ]
    );

    $schema->populate(
        'RecordContextRelationshipType',
        [
            [qw/id name/],
            [1, 'reportsTo'],
        ]
    );

    $schema->populate(
        'ItemRestrictions',
        [
            [qw/id name description/],
            [1, 'none', 'No restrictions'],
            [2, '20 years', 'Restricted 20 years'],
        ]
    );

    $schema->populate(
        'StabilizationProcedure',
        [
            [qw/id code name/],
            [1, 'ACC-007', 'Digital Media Stabilization'],
        ]
    );

    $schema->populate(
        'AuthorityName',
        [
            [qw/id name/],
            [1, 'Test Name', ''],
        ]
    );

    $schema->populate(
        'GeographicTerm',
        [
            [qw/id name/],
            [1, 'Test Geographic Term'],
        ]
    );

    $schema->populate(
        'TopicTerm',
        [
            [qw/id name/],
            [1, 'Test Topic Term'],
        ]
    );

    $schema->populate(
        'Object',
        [
            [qw/id parent number title audit_trail parent_path
                date_from date_to accession_numbers
            /],
            [1, undef, 'n1', 'Test Collection with kids', 1, '1',
                '2000-01-01', '2010-01-01', '2011.004; 2011.005', ],
            [2, undef, 'n2', 'Test Collection without kids', 2, '2', ],
            [3, 1, 'n3', 'Test Series 1', 3, '1/3', '2000-01-01', '2010-01-01',
                 '2011.004; 2011.005', ],
            [4, 3, 'n4', 'Test Item 1', 4, '1/3/4',
             '2000-01-01', '2008-01-01', '2011.004',],
            [5, 3, 'n5', 'Test Item 2', 5, '1/3/5',
             '2002-01-01', '2010-01-01', '2011.005',],
        ]
    );

    $schema->populate(
        'Collection',
        [
            [qw/id notes
                documentation processing_status/],
            [1, 'Test notes.  Unicode: « ☃ ° » yay.',
             1, 1],
            [2, 'Test notes.',
             1, 1],
        ]
    );

    $schema->populate(
        'Series',
        [
            [qw/id description/],
            [3, 'Test description.'],
        ]
    );

	# NOTES: Item 5 has no "volume", for the sake of field-based NULL searches.
	# Item 4 has volume number 'null' in order to make sure that the system can tell
	# that literal string apart from NULL. Edge-casey!
    $schema->populate(
        'Item',
        [
            [qw/id description dc_type accession_number volume/],
            [4, 'Test description.', 1, '2011.004', 'null',],
            [5, 'Test description.', 1, '2011.005', undef],
        ]
    );

    $schema->populate(
        'ObjectSetObject',
        [
            [qw/object object_set/],
            [4, 1],
            [5, 2],
        ]
    );

    $schema->populate(
        'Log',
        [
            [qw/audit_trail staff action timestamp/],
            [1, 1, 'create', '2011-01-01'],
            [1, 1, 'update', '2011-01-02'],
            [1, 1, 'update', '2011-03-01'],
            [1, 1, 'export', '2011-04-01'],
            [1, 1, 'export', '2011-05-01'],
        ]
    );

    $schema->populate(
        'CollectionMaterial',
        [
            [qw/collection material/],
            [1, 'Test Material 1'],
            [1, 'Test Material 2'],
        ]
    );

    $schema->populate(
        'CollectionLanguage',
        [
            [qw/collection language/],
            [1, 'eng'],
        ]
    );

    $schema->populate(
        'CollectionRecordContext',
        [
            [qw/collection is_primary record_context/],
            [1, 1, 1],
            [2, 1, 1],
            [2, 0, 2],
        ]
    );

    $schema->populate(
        'ItemAuthorityName',
        [
            [qw/item role name/],
            [4, 'personal_name', 1],
            [5, 'personal_name', 1],
        ]
    );

    $schema->populate(
        'UnitType',
        [
         [qw/id name volume/],
         [1, '1.2 cu. ft. box', 1.2],
         [2, 'Bound volume', undef],
         [3, 'Digital objects', undef],
        ]
    );

    $schema->populate(
        'Location',
        [
         [qw/id barcode unit_type/],
         [1, '8001', 1],
         [2, '8002', 1],
         [3, '8003', 1],
         [4, '8004', 1],
         [5, '8005', 1],
         [6, '9001', 2],
         [7, '9002', 2],
         [8, '9003', 2],
         [9, '11', 3],
         [10, '12', 3],
         [11, '13', 3],
         [12, '21', 3],
         [13, '22', 3],
        ]
    );

    $schema->populate(
        'LocationTitle',
        [
         [qw/id location title/],
         [1, 1, 'John Doe Papers'],
         [2, 1, 'Jane Doe Papers'],
        ]
    );

    $schema->populate(
        'Format',
        [
         [qw/id class name/],
         [1, 'digital_object', 'image/tiff'],
        ]
    );

    $schema->populate(
        'DigitalObject',
        [
         [qw/id item location format permanent_url pid/],
         [1, 4, 1, 1, 'http://example.com/nowhere', 'test'],
        ]
    );


    $schema->indexer->make_index;       # This clobbers any existing index.

    return $schema;
}

use XML::LibXML;

sub elt {
    return XML::LibXML->new->parse_balanced_chunk( @_ )->firstChild;
}

1;

__END__

=head1 NAME

CIDERTest

=head1 SYNOPSIS

    use lib qw(t/lib);
    use CIDERTest;
    use Test::More;

    my $schema = CIDERTest->init_schema;

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
CIDER. Shamelessly stolen from DBICTest in the DBIx::Class test
suite. (Actually it's stolen from a consulting colleague of Jason's,
who stole it in turn from DBIC...)

=head1 METHODS

=head2 init_schema

    my $schema = CIDERTest->init_schema;

This method removes the test SQLite database in t/db/cider.db
and then creates a new database populated with default test data.
It also (re)creates the search index in t/db/index.

=head1 FUNCTIONS

=head2 elt

    my $elt = elt '<foo><bar/><baz>Garply</baz></foo>';

This function parses a single XML element from a string.

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

