#!/usr/bin/env raku

use lib <../lib>;
use Date::Liturgical::Christian;

my $year  = 2022;
my $month = 12;
my $day   = 26;

my $d = Date::Liturgical::Christian.new: $year, $month, $day;


