#!/usr/bin/perl

use warnings;
use strict;

use KinoSearch::Plan::Schema;
use KinoSearch::Plan::FullTextType;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Index::Indexer;

use FindBin;
use lib (
    "$FindBin::Bin/CIDER/lib"
);     

use CIDER::Schema;

warn "Initializing...\n";

my $path_to_index = '/tmp/cider_index';
my $db_schema = CIDER::Schema->connect( 'dbi:mysql:cider', 'root', '' );

warn "connected to schema...\n";

my $object_rs = $db_schema->resultset( 'Object' );

warn "I gots a resutset...\n";

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
$index_schema->spec_field( name => 'title', type => $text_type );
$index_schema->spec_field( name => 'id', type => $storage_only );
$index_schema->spec_field( name => 'set', type => $unstored_text );

# Create one indexer object for each index.
my $indexer = KinoSearch::Index::Indexer->new(
    index => $path_to_index,
    schema => $index_schema,
    create => 1,
    truncate => 1,
);

warn "Looping...\n";

my $counter = 0;
# Start looping through the objects.
# Each will get a document in the searchable index.
my $mod = 1;
while ( my $object = $object_rs->next ) {
    if ( $counter++ % $mod == 0 ) {
	warn "On object $counter.\n";
    }
    my $doc = {
	title => $object->title || '',
	id => $object->id || '',
    };

    use Data::Dumper; warn Dumper ( $doc );
    
    my @sets = $object->sets;
    my $sets = join ' ', map { $_->id } @sets;
    $doc->{ set } = $sets || '';

    $indexer->add_doc( $doc );
    last if $counter > 100;
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
