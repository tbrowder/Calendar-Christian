use Test;
use Date::Liturgical::Christian;

plan 8;

my ($d, $e);

# 2006-11-26      white     Advent Advent Sunday
# 2021-11-28
# 2022-11-27

#$d = Advent-Sunday2 2006;
#is $d.month, 11;
#is $d.day, 26;

$d = Advent-Sunday 2021;
$e = Advent-Sunday2 2021;
is $d.month, 11;
is $d.day, 28;
is $e.month, 11;
is $e.day, 28;

$d = Advent-Sunday 2022;
$e = Advent-Sunday2 2022;
is $d.month, 11;
is $d.day, 27;
is $e.month, 11;
is $e.day, 27;
