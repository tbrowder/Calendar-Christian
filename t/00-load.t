use Test;
use Date::Liturgical::Christian;

plan 1;

my $c = Date::Liturgical::Christian.new(2022, 1, 2);
isa-ok $c, Date::Liturgical::Christian;
