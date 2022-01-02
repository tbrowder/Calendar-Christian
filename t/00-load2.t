use Test;
use Date::Liturgical::Christian::Day;

plan 4;

my $c;

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
