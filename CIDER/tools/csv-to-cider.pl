#!/tdr/bin/bin/perl 

# turn CSV files into CIDER import files

use strict;
use warnings;
use Log::Log4perl qw(get_logger :levels);
use File::Basename;
use XML::LibXML;
use XML::LibXML::XPathContext;
use Text::CSV;
use Text::CSV::Encoded;
use Template;

######
# Set the program variables
######
my ($program_name, $dirname) = fileparse($0);
my $LOGFILE = "me)$program_name.log";
my $includesdir = "includes";

######
# Initialize logging 
######
Log::Log4perl->easy_init($INFO);
my $logger = get_logger();

my $layout =
  Log::Log4perl::Layout::PatternLayout->new("%d %p: %F{1}:%L %M - %m%n");

my $appender = Log::Log4perl::Appender->new(
  "Log::Dispatch::File",
  filename => $LOGFILE,
  mode     => "append",
  layout   => $layout,
);

$logger->add_appender($appender);
$logger->info("\n\n===\nRunning $0 at ", scalar(localtime(time)), "\n===");

######
# Set up the template toolkit objects and configuration
######
my $config = {
    INCLUDE_PATH => $dirname,
    POST_CHOMP => 1,
};
my $input = 'cider-include.tt';
my $tt = Template->new( $config );

######
# Argument check
######
my $batchname = $ARGV[0]
  or $logger->logdie("Usage: $0 [csv file]\n");

######
# Parse the CSV file
######

# Use Text::CSV to parse the CSV file. The metadata are Unicode!
my $csv = Text::CSV::Encoded->new({ encoding => "utf8" });

open my $csv_fh, "<", $batchname
  or $logger->logdie("Can't parse CSV file: $!\n");

my $output = basename($batchname) . "-include.xml";
open my $out_fh, ">", $output
  or $logger->logdie("Can't open output file for writing: $!\n");

# add the header information
print $out_fh qq{<?xml-model href="http://dca.lib.tufts.edu/schema/cider/cider-import.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"?>};
print $out_fh "\n<import>\n";

# Set the names of the keys in the hash we are going to use to something
# meaningful so the template is readable.
$csv->column_names( $csv->getline ( $csv_fh ) );

# Load each row of the CSV file into a hash, and process using the template
until ( eof( $csv_fh ) ) {
    # Read each line of the CSV file and verify necessary values
    my $row_ref = $csv->getline_hr( $csv_fh );
    $row_ref =~ s/&(\s)/&amp;$1/g;

    if ( $row_ref ) {
        # set the name for the include file
        if ( !defined $row_ref->{'ObjectID'} ) {
            $logger->logwarn("row id for \"$row_ref->{'title'}\" doesn't exist: $!\n");
        }

        # split the fields which might have multiple values
        my @creators = split(/\|/, $row_ref->{'creators'});
        $row_ref->{'creators'} = \@creators;

        my @personalNames = split(/\|/, $row_ref->{'personalNames'});
        $row_ref->{'personalNames'} = \@personalNames;

        my @corporateNames = split(/\|/, $row_ref->{'corporateNames'});
        $row_ref->{'corporateNames'} = \@corporateNames;

        my @topicTerms = split(/\|/, $row_ref->{'topicTerms'});
        $row_ref->{'topicTerms'} = \@topicTerms;

        my @geographicTerms = split(/\|/, $row_ref->{'geographicTerms'});
        $row_ref->{'geographicTerms'} = \@geographicTerms;

        my @applicationOther = split(/\|/, $row_ref->{'applicationOther'});
        $row_ref->{'applicationOther'} = \@applicationOther;
               
        my ($first, $last);
        ($first = $row_ref->{'stabilizationBy'}) =~ s/[^,]*, (.*)/$1/;
        ($last = $row_ref->{'stabilizationBy'}) =~ s/([^,]*), .*/$1/;
        my @stabilizationBy = (
            $first, 
            $last,
        );
        $row_ref->{'stabilizationBy'} = \@stabilizationBy;

        # Pass the row of the csv file to template toolkit to create a single include file
        my $vars = { obj => $row_ref };
        $tt->process( $input, $vars, $out_fh )
           or die $tt->error();
    } else {
       $logger->logwarn("row $. can't parse: $!\n");
    }

}
$csv->eof or $csv->error_diag();

print $out_fh "\n</import>\n";

close $csv_fh;
close $out_fh;

=head1 NAME

CSV to CIDER

=head1 SYNOPSIS

    toold/csv-to-cider [input csv]

=head1 DESCRIPTION

Populate a spreadsheet with metadata according to the spreadsheet
in metadata_blank.xslx (in the tools directory). (Columns have
directions, and there is a second sheet called README with more
detailed directions.) Save the main worksheet as Comma Separated
Values, and then run this script on that CSV file to generate a
cider import file.

=head1 AUTHORS

Deborah Kaplan

=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

1;
