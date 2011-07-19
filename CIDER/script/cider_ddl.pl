#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

my @args = ( [ 'MySQL' ], undef, "$FindBin::Bin/.." );

use CIDER::Schema;
my $schema = CIDER::Schema->connect;
unlink( $schema->ddl_filename( @args ) );
$schema->create_ddl_dir( @args );
