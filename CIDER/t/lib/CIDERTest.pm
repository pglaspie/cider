package CIDERTest;
use strict;
use warnings;

use FindBin;

$ENV{CIDER_SITE_CONFIG} = "$FindBin::Bin/conf/cider.conf";
#$ENV{CIDER_DEBUG}       = 0;

use Carp qw(croak);
use English;

use CIDER::Schema;

sub init_schema {
    my $self = shift;
    my %args = @_;

    my $db_dir  = "$FindBin::Bin/db";
    my $db_file = "$db_dir/cider.db";

    if (-e $db_file) {
        unlink $db_file
            or croak("Couldn't unlink $db_file: $OS_ERROR");
    }

    my $schema = CIDER::Schema->
        connect("dbi:SQLite:$db_file", '', '', {
            on_connect_call => 'use_foreign_keys',
        });

    $schema->deploy;
    __PACKAGE__->populate_schema($schema);

    return $schema;
}

sub populate_schema {
    my $self   = shift;
    my $schema = shift;

    $schema->populate(
        'RecordContext',
        [
            [qw/id name/],
            [1, 'Context 1'],
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
        'ProcessingStatus',
        [
            [qw/id name/],
            [1, 'Test Status'],
        ]
    );

    $schema->populate(
        'ItemType',
        [
            [qw/id name/],
            [1, 'Test Type'],
        ]
    );

    $schema->populate(
        'AuthorityName',
        [
            [qw/id value/],
            [1, 'Test Status'],
        ]
    );

    $schema->populate(
        'Object',
        [
            [qw/id parent number title personal_name corporate_name
               topic_term geographic_term notes date_from date_to
               record_context has_physical_documentation
               type/],
            [1, undef, 12345, 'Test Collection with kids', 1, undef,
             undef, undef, 'Test notes.', undef, undef,
             1, 0,
             undef
            ],
            [2, undef, 12345, 'Test Collection without kids', 2, undef,
             undef, undef, 'Test notes.', undef, undef,
             1, 0,
             undef
            ],
            [3, 1, 12345, 'Test Series 1', 1, undef,
             undef, undef, 'Test notes.', undef, undef,
             undef, undef,
             undef,
            ],
            [4, 3, 12345, 'Test Item 1', 1 , undef,
             undef, undef, 'Test notes.', '2000-01-01', '2008-01-01',
             undef, undef,
             1,
            ],
            [5, 3, 12345, 'Test Item 2', 1 , undef,
             undef, undef, 'Test notes.', '2002-01-01', '2010-01-01',
             undef, undef,
             1,
            ],
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
        'LocationUnitType',
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
         [qw/barcode unit_type/],
         ['8001', 1],
         ['8002', 1],
         ['8003', 1],
         ['8004', 1],
         ['8005', 1],
         ['9001', 2],
         ['9002', 2],
         ['9003', 2],
         ['11', 3],
         ['12', 3],
         ['13', 3],
         ['21', 3],
         ['22', 3],
        ]
    );

    $schema->populate(
        'LocationTitle',
        [
         [qw/id location title/],
         [1, '8001', 'John Doe Papers'],
         [2, '8001', 'Jane Doe Papers'],
        ]
    );

}

1;

__END__

=head1 NAME

CIDERTest

=head1 SYNOPSIS

    use lib qw(t/lib);
    use CIDERTest;
    use Test::More;

    my $schema = CIDERTest->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
CIDER. Shamelessly stolen from DBICTest in the DBIx::Class test
suite. (Actually it's stolen from a consulting colleague of Jason's,
who stole it in turn from DBIC...)

=head1 METHODS

=head2 init_schema

    my $schema = CIDERTest->init_schema();

This method removes the test SQLite database in t/TestSite/db/mhs.db
and then creates a new, empty database.

This method will call deploy_schema() to create the db schema,
and populate_schema() to insert default data.

=head2 deploy_schema

    CIDERTest->deploy_schema( $schema );

This method calls $schema->deploy() to create the db schema based on the DBIC
schema.

=head2 populate_schema

  CIDERTest->populate_schema( $schema );

After you deploy your schema you can use this method to populate
the tables with test data.

