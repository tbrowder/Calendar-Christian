use Test;
use Date::Liturgical::Christian;

# test the indexing subs

plan 4;

my ($m, $d, $idx);

{
    $m = 1; $d = 1; my $idx = 10101;
    is to-index-rel-christmas($m, $d), $idx;
}

{
    $m = 12; $d = 31; my $idx = 11231;
    is to-index-rel-christmas($m, $d), $idx;
}

{
    $m = 1; $d = 1; my $idx = 10101;
    is from-index-rel-christmas($idx), ($m, $d);
}
{
    $m = 12; $d = 31; my $idx = 11231;
    is from-index-rel-christmas($idx), ($m, $d);
}
