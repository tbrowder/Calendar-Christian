use Test;
use Date::Liturgical::Christian;

plan 2;

my $c;
my %opts = year => 2022, month => 1, day => 2;

$c = Date::Liturgical::Christian.new(2022, 1, 2);
isa-ok $c, Date::Liturgical::Christian;

$c = Date::Liturgical::Christian.new(2022, 1, 2, :transferred(1));
isa-ok $c, Date::Liturgical::Christian;