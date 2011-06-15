#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib"
);

use CIDER;

my $indexer = CIDER->model( 'Search' )->indexer;
my $count = $indexer->make_index;

warn "Indexed $count objects.\n";
