#!/usr/bin/env raku

use Test;
use DateTime::Julian;

# some test data for date2days (Date_To_Days)
# 1,1,1 returns 1
# 1,12,31 returns 365
# 2,1,1 returns 366
# 1998,5,1 returns 729510

my $days;
my $dt;

$dt = days2date 1;
is $dt.year, 1;
is $dt.month, 1;
is $dt.day, 1;

$dt = days2date 365;
is $dt.year, 1;
is $dt.month, 12;
is $dt.day, 31;

$dt = days2date 366;
is $dt.year, 2;
is $dt.month, 1;
is $dt.day, 1;

$dt = days2date 729510;
is $dt.year, 1998;
is $dt.month, 5;
is $dt.day, 1;

$days = date2days 1, 1, 1;
is $days, 1;

$days = date2days 1, 12, 31;
is $days, 365;

$days = date2days 2, 1, 1;
is $days, 366;

$days = date2days 1998, 5, 1;
is $days, 729510;

sub date2days($year, $month, $day) is export {
    # calc days from 1,1,1 AD
    my $d0 = DateTime.new(:1year, :1month, :1day);
    DateTime.new(:$year, :$month, :$day).julian-date - $d0.julian-date + 1
}

sub days2date($days --> Date) is export {
    my $d0 = Date.new: 1, 1, 1;
    $d0 + $days - 1
}

