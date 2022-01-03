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

my $dstart = Date.new: $year, 1, 1;
my $d = $dstart;
while $d.year < $year+1 {
    last if $ndays and $d.day-of-year > $ndays;

    # get and print the current day's data 
    say $d;

    ++$d;
}

=finish

my $year  = 2022;
my $month = 12;
my $day   = 26;

my $d = Date::Liturgical::Christian.new: $year, $month, $day;



