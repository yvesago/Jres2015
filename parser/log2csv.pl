#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Getopt::Long;
use lib "lib/";
use feature 'say';

use MyLdapLog;


my ($logfile,$help);

sub usage {
  say " ./log2csv.pl [-h] file";

  exit 1;
};

GetOptions(
    'help|h'         => \$help,
#    'logtype|m'       => \$logtype, # TODO for multi log type
);

### print a nice usage message
if ($help) {
    usage;
    exit 1;
}

### Make sure there is at least one logfile
if ( !@ARGV ) {
    usage;
    exit 1;
}


###################################################
### Open the logfile and process all of the entries
###################################################

my $p = MyLdapLog->new;

say $p->head;

for my $file (@ARGV) {
    $logfile = $file;
    my $lines = 0;

    ### find open filter to use
    my $openfilter = '<' . $logfile . q{};

    ### decode gzipped / bzip2-compressed files
    if ( $logfile =~ /\.bz2$/mx ) {
        $openfilter = q{bzip2 -dc "} . $logfile . q{"|}
          or carp "Problem decompressing!: $!\n";
    }

    if ( $logfile =~ /\.(gz|Z)$/mx ) {
        $openfilter = q{gzip -dc "} . $logfile . q{"|}
          or carp "Problem decompressing!: $!\n";
    }

    ### If the logfile isn't valid, move on to the next one
    if ( !open LOGFILE, $openfilter ) {
        print "ERROR: unable to open '$logfile': $!\n";
        next;
    }
   while ( my $line = <LOGFILE> ) {
     my $res = $p->parse($line);
     say $res if($res);
   }
}
