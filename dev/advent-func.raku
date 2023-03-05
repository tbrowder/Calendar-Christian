#!/usr/bin/env raku

use lib <../lib>;
use Date::Liturgical::Christian;
use Date::Easter;

if not @*ARGS {
    put qq:to/HERE/;
    Usage: {$*PROGRAM.basename} YYYY [N]

    Prints a daily list of liturgical data for
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
    my $epr = $ld.ep;
    my $cpr = $ld.cp;
    my $adr = $ld.ad;

    my $epp = easter-point $ld;
    my $cpp = christmas-point $ld;
    my $adp = advent $ld;

    my $err = 0;
    my $msg = '';
    
    if $epr != $epp {
        ++$err;
        $msg ~= 'Ep ';
    }
    if $cpr != $cpp {
        ++$err;
        $msg ~= 'Cp ';
    }
    if $adr != $adp {
        ++$err;
        $msg ~= 'Ap ';
    }

    if $err {
        note "DEBUG err in '$msg': $d ep/cp/ad raku/perl: $epr/$cpr/$adr  $epp/$cpp/$adp"
    }

    ++$d;
}

# the Perl calcs
sub easter-point(Date $dt) {
    use Date::Calc:from<Perl5> 'Date_to_Days';
    my $y = $dt.year;
    my $m = $dt.month;
    my $d = $dt.day;
    my $days = Date_to_Days($y, $m, $d);

    my $Easter = Date.new(Easter $y);
    ($days - Date_to_Days($y, $Easter.month, $Easter.day));
}

sub christmas-point(Date $dt) {
    use Date::Calc:from<Perl5> 'Date_to_Days';
    my $y = $dt.year;
    my $m = $dt.month;
    my $d = $dt.day;
    my $days = Date_to_Days($y, $m, $d);
    if  $m > 2 {
        $days -= Date_to_Days($y, 12, 25);
    }
    else {
        $days -= Date_to_Days($y-1, 12, 25);
    }
    $days
}

sub advent(Date $dt) {
    use Date::Calc:from<Perl5> 'Day_of_Week';
    my $y = $dt.year;
    my $days = -(Day_of_Week($y, 12, 25) + 4*7);
    $days
}

=finish
sub date2days(Date $d) {
    use Date::Calc:from<Perl5> ':all';
    my $y = $d.year;
    my $m = $d.month;
    my $d = $d.day;
    my $days = Date_to_Days($y, $m, $d);
}

sub days2date($days) {
    use Date::Calc:from<Perl5> ':all';
}

