#!/usr/bin/env raku

use HTTP::UserAgent;

my $year = Date.new(now).year;
if !@*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.basename} yyyy

    Gets the pdf UMC liturgical calendar for year YYYY.
    HERE
    exit;
}

my $arg = @*ARGS.shift;
if $arg ~~ /^ (\d\d\d\d) $/ {
    $year = ~$0;
}
else {
    note "FATAL: Arg is not YYYY, it's '$arg'";
    exit;
}

my $ua = HTTP::UserAgent.new;
$ua.timeout = 10;
my $begin-path = "https://s3.us-east-1.amazonaws.com/gbod-assets/generic/";
my $end-path   = "SundaysSpecialDays_2PGCalendar_{$year}.pdf";
my $uri        = $begin-path ~ $end-path;
my $response   = $ua.get($uri);
if $response.is-success {
    spurt $end-path, $response.content;
}
else {
    die $response.status-line;
}

say "See output file:";
say "  $end-path";
