use Test;
use Date::Liturgical::Christian::Day;

plan 24;

my $c;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;

my $tradition   = 'ECUSA';
my $advent-blue = 0;
my $bvm-blue    = 0;
my $rose        = 0;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2,
                 :$tradition,
                 :$advent-blue,
                 :$bvm-blue,
                 :$rose);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2,
                 :$tradition);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2,
                 :$advent-blue);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2,
                 :$bvm-blue);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;

$c = Date::Liturgical::Christian::Day.new(2022, 1, 2,
                 :$rose);
isa-ok $c, Date::Liturgical::Christian::Day;
is $c.year, 2022;
is $c.month, 1;
is $c.day, 2;
