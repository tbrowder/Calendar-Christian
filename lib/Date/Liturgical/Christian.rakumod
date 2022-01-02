use Date::Christian::Advent;
use Date::Easter;

unit class Date::Liturgical::Christian is Date; 
# a child class of Date

use Date::Liturgical::Christian::Feasts;
use Date::Liturgical::Christian::Day;

my $debug = 0;

multi method new($year, $month, $day, 
                 :$tradition   = 'ECUSA', # Episcopal Church USA
                 :$advent-blue = 0,
                 :$bvm-blue    = 0,
                 :$rose        = 0,
                ) {
    # Convert the input values to a Date object. Following code thanks
    # to @lizmat on IRC #raku, 2021-11-18, 06:08
    # (and on IRC #raku, 2021-03-29, 11:50)
    self.Date::new($year, $month, $day);
}

# constructor named options
has $.tradition; #   = 'ECUSA'; # Episcopal Church USA #has $.tradition   = 'UMC'; # United Methodist Church
has $.advent-blue = 0;
has $.bvm-blue    = 0;
has $.rose        = 0;

=begin comment
# outputs for an input year, month, day:
has $.name   is rw = '';
has $.season = '';
has $.color  = '';
has $.bvm    = '';
has $.weekno = '';
=end comment

=begin comment
has $.martyr = '';
=end comment

has Date $!Easter;

submethod TWEAK {
    my $days = self.day-of-year;
    my $y    = self.year;
    my $m    = self.month;
    my $d    = self.day;
    my $dow  = self.day-of-week;

    $!Easter = Easter($y);

    my @possibles;
}

=begin comment
method color  { self.result<color> // '' }
method name   { self.result<name> // '' }
method season { self.result<season> // '' }
method prec   { self.result<prec> // '' }
=end comment

sub to-index-rel-christmas($month, $day) is export {
    # Dates relative to Christmas are encoded to the index as 10000 + 100*m + d
    # for simplicity.
    # Example: m=1, d=1 => 10000 + 100*1 + 1 = 10000+100+1 = 10101
    # Example: m=12, d=31 => 10000 + 100*12 + 1 = 10000+1200+31 = 11231
    10000 + 100*$month + $day
}

sub from-index-rel-christmas($index --> List) is export {
    # Dates relative to Christmas are decoded from 10000 + 100*m + d.
    my $md = $index - 10000;
    my $m = $md div 100;
    my $d = $md mod 100;
    $m, $d
}
