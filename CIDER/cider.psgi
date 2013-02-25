use strict;
use warnings;

use FindBin::libs;
use CIDER;

my $app = CIDER->apply_default_middlewares(CIDER->psgi_app);
$app;

