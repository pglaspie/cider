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
use CIDER::Logic::Indexer;

my $path_to_index = CIDER->config->{ 'Model::Search' }->{ index };
my $connect_info = CIDER->config->{ 'Model::CIDERDB' }->{ connect_info };

my $indexer = CIDER::Logic::Indexer->new( $connect_info, $path_to_index );
my $count = $indexer->make_index;

warn "Indexed $count objects.\n";
