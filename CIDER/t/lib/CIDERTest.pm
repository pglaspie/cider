package CIDERTest;
use strict;
use warnings;

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
        'RecordContextType',
        [
            [qw/id name/],
            [1, 'corporateBody'],
        ]
    );

    $schema->populate(
        'RecordContext',
        [
            [qw/id record_id name_entry rc_type/],
            [1, 'RCR00001', 'Context 1', 1],
        ]
    );

    $schema->populate(
        'User',
        [
            [qw/id username password/],
            [1, 'alice', 'foo',],
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
            [1, 'test_status', 'Test Status'],
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
            [1, 'Test Type'],
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
            [qw/id parent number title/],
            [1, undef, 'n1', 'Test Collection with kids'],
            [2, undef, 'n2', 'Test Collection without kids'],
            [3, 1, 'n3', 'Test Series 1'],
            [4, 3, 'n4', 'Test Item 1'],
            [5, 3, 'n5', 'Test Item 2'],
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

    $schema->populate(
        'Item',
        [
            [qw/id description date_from date_to dc_type/],
            [4, 'Test description.', '2000-01-01', '2008-01-01', 1],
            [5, 'Test description.', '2002-01-01', '2010-01-01', 1],
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
            [qw/user object action timestamp/],
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
         [2, 'bound volume', undef],
         [3, 'digital object', undef],
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

    $schema->indexer->make_index;       # This clobbers any existing index.

    return $schema;
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
