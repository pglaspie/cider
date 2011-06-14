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

use CIDER;
my $c = CIDER->new;
my $searcher = $c->model( 'Search' );
my $hits = $searcher->hits( query => 'Test Item' );
is( $hits->total_hits, 2, 'Found two Test Items.' );
is( $hits->next->{title}, 'Test Item 1', 'Found Test Item 1.' );
is( $hits->next->{title}, 'Test Item 2', 'Found Test Item 2.' );

done_testing();
