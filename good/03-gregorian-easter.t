# Copied from Perl module Date::Easter and modified for Raku and this
# module.

use Test;
use Date::Liturgical::Christian;

plan 16;

my $d;

$d = Easter 1990;
is $d.month, 4, "1990 - April (Got $d.month)";
is $d.day, 15, "1990 - April 15 (Got $d.day)";

$d = Easter 1991;
is $d.month, 3, "1991 - March (Got $d.month)";
is $d.day, 31, "1991 - March 31 (Got $d.day)";

$d = Easter 1992;
is $d.month, 4, "1992 - April (Got $d.month)";
is $d.day, 19, "1992 - April 19 (Got $d.day)";

$d = Easter 2000;
is $d.month, 4, "2000 - April (Got $d.month)";
is $d.day, 23, "2000 - April 23 (Got $d.day)";

$d = Easter 2001;
is $d.month, 4, "2001 - April (Got $d.month)";
is $d.day, 15, "2001 - April 15 (Got $d.day)";

$d = Easter 2002;
is $d.month, 3, "2002 - March (Got $d.month)";
is $d.day, 31, "2002 - March 31 (Got $d.day)";

$d = Easter 2021;
is $d.month, 4, "2021 - April (Got $d.month)";
is $d.day, 4, "2021 - April 4 (Got $d.day)";

$d = Easter 2022;
is $d.month, 4, "2022 - April (Got $d.month)";
is $d.day, 17, "2022 - April 17 (Got $d.day)";
