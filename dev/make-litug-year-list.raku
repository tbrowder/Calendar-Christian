#!/usr/bin/env raku

use lib <../lib>;
use Date::Liturgical::Christian;

if not @*ARGS {
    put qq:to/HERE/;
    Usage: {$*PROGRAM.basename} YYYY [N]

    Prints a daily list of liturgical events for
      year YYYY,
    Prints only N days if entered.
    HERE
    exit;
}

my $year = @*ARGS.shift;
die "FATAL: Year '$year' is not a valid year." if $year !~~ /\d**4/;

my $ndays = @*ARGS.elems ?? @*ARGS.shift !! 0;
die "FATAL: N '$ndays' is not a valid number." if $ndays !~~ /\d+/;

my $debug = 0;

my $dstart = Date.new: $year, 1, 1;
my $d = $dstart;
while $d.year < $year+1 {
    my $doy = $d.day-of-year;

    last if $ndays and $doy > $ndays;


    # get and print the current day's data 
    my $ld = Date::Liturgical::Christian.new: $d.year, $d.month, $d.day;
    note "DEBUG: $d season {$ld.season}; easter point {$ld.ep}; christmas point {$ld.cp}; advent {$ld.ad}" if 1 or $debug;

    # show the named feast from Christmas and Easter for the day, if any.
    #say $ld.raku;

    ++$d;
}

=finish

my $year  = 2022;
my $month = 12;
my $day   = 26;

my $d = Date::Liturgical::Christian.new: $year, $month, $day;



