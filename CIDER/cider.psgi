use strict;
use warnings;

use CIDER;

my $app = CIDER->apply_default_middlewares(CIDER->psgi_app);
$app;

