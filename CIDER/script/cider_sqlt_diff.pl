#!/usr/bin/perl

# A wrapper around sqlt-diff, to make it callable by svn diff.
# Use it like so:
#
# svn diff cider.sql --diff-cmd script/cider_sqlt_diff.pl

use warnings;
use strict;

my @cmd = qw(sqlt-diff --ignore-index-names --ignore-constraint-names);

my $i = 0;
while ( $i <= $#ARGV ) {
    my $arg = $ARGV[$i++];
    if ( $arg =~ /^-L$/ ) {
        print '-- ', $ARGV[$i++], "\n";
    }
    elsif ( $arg !~ /^-/ ) {
        push @cmd, "$arg=MySQL";
    }
}

exec @cmd;
