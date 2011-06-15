use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'CIDER::Model::Search' }

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
CIDERTest->init_schema;
CIDERTest->init_index;

use CIDER;
my $searcher = CIDER->model( 'Search' );
my $hits = $searcher->hits( query => 'Item' );
is( $hits->total_hits, 2, 'Found two Items.' );
is( $hits->next->{title}, 'Test Item 1', 'Found Test Item 1.' );
is( $hits->next->{title}, 'Test Item 2', 'Found Test Item 2.' );

done_testing();
