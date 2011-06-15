#!/usr/bin/perl

use warnings;
use strict;

use KinoSearch::Plan::Schema;
use KinoSearch::Plan::FullTextType;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Index::Indexer;

use FindBin;
use lib (
    "$FindBin::Bin/../lib"
);     

use CIDER;
use CIDER::Schema;

my $path_to_index = CIDER->config->{ 'Model::Search' }->{ index };
my $connect_info = CIDER->config->{ 'Model::CIDERDB' }->{ connect_info };
my $db_schema = CIDER::Schema->connect( $connect_info );
my $object_rs = $db_schema->resultset( 'Object' );

# Create the index schema.
# We'll try to have all the indexes share the same one...
my $index_schema = KinoSearch::Plan::Schema->new;
my $polyanalyzer = KinoSearch::Analysis::PolyAnalyzer->new(
    language => 'en',
    );

# Define some basic types. Just being coarse for now.
my $text_type = KinoSearch::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 1,
);

my $unstored_text = KinoSearch::Plan::FullTextType->new(
    analyzer => $polyanalyzer,
    sortable => 0,
    stored   => 0,
);

my $string_type = KinoSearch::Plan::StringType->new( sortable => 1 );
my $storage_only = KinoSearch::Plan::StringType->new( indexed => 0 );
my $index_only = KinoSearch::Plan::StringType->new( stored => 0 );
my $int_type    = KinoSearch::Plan::Int32Type->new;

# Define the fields.
my @text_fields = qw(
accession_by
accession_number
accession_procedure
arrangement
checksum
checksum_app
description
file_extension
funder
handle
history
lc_class
media_app
notes
number
organization
original_filename
other_app
permanent_url
pid
processing_notes
publication_status
rsa
stabilization_by
stabilization_notes
stabilization_procedure
technical_metadata
title
toc
virus_app
);

for my $field ( @text_fields ) {
    $index_schema->spec_field( name => $field, type => $text_type );
}

$index_schema->spec_field( name => 'id', type => $storage_only );
$index_schema->spec_field( name => 'set', type => $unstored_text );


# Create one indexer object for each index.
my $indexer = KinoSearch::Index::Indexer->new(
    index => $path_to_index,
    schema => $index_schema,
    create => 1,
    truncate => 1,
);

# Start looping through the objects.
# Each will get a document in the searchable index.
while ( my $object = $object_rs->next ) {
    my $doc = {
	id => $object->id || '',
    };

    for my $field ( @text_fields ) {
        $doc->{ $field } = $object->$field || '';
    }

    my @sets = $object->sets;
    my $sets = join ' ', map { $_->id } @sets;
    $doc->{ set } = $sets || '';

    $indexer->add_doc( $doc );
}

$indexer->commit;

sub normalize {
    my ( $name ) = @_;
    $name =~ s/\s+\W+\s+/_/g;
    $name =~ s/\s+/_/g;
    $name =~ s/\W//g;
    $name = lc $name;
    return $name;
}
