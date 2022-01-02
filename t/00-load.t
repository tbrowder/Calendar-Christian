use Test;
use Date::Liturgical::Christian;

plan 6;

my $c;

$c = Date::Liturgical::Christian.new(2022, 1, 2);
isa-ok $c, Date::Liturgical::Christian;

my $tradition   = 'ECUSA';
my $advent-blue = 0;
my $bvm-blue    = 0;
my $rose        = 0;

$c = Date::Liturgical::Christian.new(2022, 1, 2,
                 :$tradition,
                 :$advent-blue,
                 :$bvm-blue,
                 :$rose);
isa-ok $c, Date::Liturgical::Christian;

$c = Date::Liturgical::Christian.new(2022, 1, 2,
                 :$tradition);
isa-ok $c, Date::Liturgical::Christian;

$c = Date::Liturgical::Christian.new(2022, 1, 2,
                 :$advent-blue);
isa-ok $c, Date::Liturgical::Christian;

$c = Date::Liturgical::Christian.new(2022, 1, 2,
                 :$bvm-blue);
isa-ok $c, Date::Liturgical::Christian;

$c = Date::Liturgical::Christian.new(2022, 1, 2,
                 :$rose);
isa-ok $c, Date::Liturgical::Christian;
