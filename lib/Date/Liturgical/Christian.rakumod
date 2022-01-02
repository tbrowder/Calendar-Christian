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

# line 189 (line 297 - 189 = 108 lines following this line
=begin comment
    #======================================================
    # all below here belongs to Date::Liturgical::Christian
    #======================================================

    #my $result = ${dclone(\($possibles[0]))};
    # TODO if @possibles[0] is a persistent class, restore its result
    $!result = @possibles[0];

    if not $!result {
        $!result = { name => '', prec => 1 };
    }

    # TODO fix this:
    #$result = { %opts, %$result, season=>$!season, weekno=>$weekno };
    $!result<season> = $season;
    $!result<weekno> = $weekno;

    #if %opts{rose} {
    if $!rose {
        my %rose-days = [ 'Advent 2' => 1, 'Lent 3' => 1 ];
        #$result->{colour} = 'rose' if %rose_days{$result->{name}};
        $!result<color> = 'rose' if %rose-days{$!result<name>:exists} and %rose-days{$!result<name>};
    }

    # TODO fix this
    #if !defined $result<color> {
    unless $!result<color>:exists {
        if $!result<prec> > 2 && $!result<prec> != 5 {
            # Feasts are generally white,
            # unless marked differently.
            # But martyrs are red, and Marian
            # feasts *might* be blue.
            if $!result<martyr>:exists {
                $!result<color> = 'red';
            }
            elsif $!bvm-blue && ($!result<bvm>:exists) {
                $!result<color> = 'blue';
            }
            else {
                $!result<color> = 'white';
            }
        }
        else {
            # Not a feast day.
            if $season eq 'Lent' {
                $!result<color> = 'purple';
            }
            elsif $season eq 'Advent' {
                if $!advent-blue {
                    $!result<color> = 'blue';
                }
                else {
                    $!result<color> = 'purple';
                }
            }
            else {
                # The great fallback:
                $!result<color> = 'green';
            }
        }
    }

    # Two special cases for Christmas-based festivals which depend on
    # the day of the week.

    if $!result<prec> == 5 { # An ordinary Sunday
        if $christmas-point == $advent-sunday {
            $!result<name> = 'Advent Sunday';
            $!result<color> = 'white';
        }
        elsif $christmas-point == $advent-sunday -7 {
            $!result<name> = 'Christ the King';
            $!result<color> = 'white';
        }
    }

    if $debug {
        note "DEBUG: dumping var \$result hash:";
        #note $result.raku;
        note $!result.raku;
    }

    =begin comment
    for $!result.kv -> $k, $v {
        note "DEBUG: result key '$k' => '$v'" if $debug;
        given $k {
            when $k eq 'color'  { $!color  = $v }
            when $k eq 'name'   { $!name   = $v }
            when $k eq 'season' { $!season = $v }
            when $k eq 'bvm'    { $!bvm    = $v }
            when $k eq 'martyr' { $!martyr = $v }

            if $debug {
                when $k eq 'weekno' { note "DEBUG: Skipping key 'weekno'" }
                when $k eq 'prec'   { note "DEBUG: Skipping key 'prec'" }
                default {
                    die "FATAL DEV: unhandled key '$k'"
                }
            }
        }
    }
    =end comment
    #======================================================
    # all above here belongs to Date::Liturgical::Christian
    #======================================================

=end comment
# line 297
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
