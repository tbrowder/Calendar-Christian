use Test;
use Date::Liturgical::Christian;
use Text::Utils :strip-comment;

plan 8;

my ($d, $e);

# original test data had wrong date for first Advent Sunday!
# WRONG! 2006-11-26      white     Advent Advent Sunday
my $advents = q:to/HERE/;
2004-11-28 # web search
2005-11-27 # web search
2006-12-03 # web search
2007-12-02 # web search
2008-11-30 # web search
2009-11-29 # web search
2010-11-28 # web search
2011-11-27 # web search
2012-12-02 # web search
2013-12-01 # web search
2014-11-30 # web search
2015-11-29 # web search
2016-11-27 # web search
2017-12-03 # web search
2018-12-02 # web search
2019-12-01 # web search
2020-11-29 # web search
2021-11-28 # UMC doc
2022-11-27 # UMC doc
2023-12-03 # web search
2024-12-01 # web search
2025-11-30 # web search
HERE

my $n = $advents.lines.elems;
my $nt = $n * 6;
plan $nt;

for $advents.lines -> $line is copy {
    $line = strip-comment $line;
    my $date = $line.words[0];
    my $t = Date.new: $date;

    my $a = Advent-Sunday  $t.year;
    is $a.month, $t.month;
    is $a.day, $t.day;
    
    my $b = Advent-Sunday2 $t.year;
    is $b.month, $t.month;
    is $b.day, $t.day;
    
    my $c = Advent-Sunday3 $t.year;
    is $c.month, $t.month;
    is $c.day, $t.day;
}
    
