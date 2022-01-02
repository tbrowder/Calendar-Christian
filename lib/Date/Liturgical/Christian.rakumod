use Date::Christian::Advent;
use Date::Easter;

unit class Date::Liturgical::Christian is Date; 
# a child class of Date

use Date::Liturgical::Christian::Feasts;

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

=begin comment
submethod TWEAK {
    my $days = self.day-of-year;
    my $y    = self.year;
    my $m    = self.month;
    my $d    = self.day;
    my $dow  = self.day-of-week;

    $!Easter = Easter($y);

    my @possibles;

    # "The Church Year consists of two cycles of feasts and holy days:
    #  one is dependent upon the movable date of the Sunday of the
    #  Resurrection or Easter Day; the other, upon the fixed date of
    #  December 25, the Feast of our Lord's Nativity or Christmas
    #  Day."

    my Int $easter-point = $days - $!Easter.day-of-year;
    my Int $christmas-point;

    # We will store the amount of time until (-ve) or since (+ve)
    # Christmas in $christmas-point. Let's make the cut-off date the
    # end of February, since we'll be dealing with Easter-based dates
    # after that, it avoids the problems of considering leap years.

    if $m > 2 {
        $christmas-point = $days - Date.new($y, 12, 25).day-of-year;
    }
    else {
        $christmas-point = $days - Date.new($y-1, 12, 25).day-of-year;
    }

    # First, figure out the season.
    my $season;
    my $weekno;

    my $advent-sunday = Advent-Sunday($y).day-of-year;

    #if $easter-point > -47 && $easter-point < 0 {
    if  -47 < $easter-point < 0 {
        $season = 'Lent';
        $weekno = ($easter-point+50)/7;
        $weekno = $weekno.Int;
        # FIXME: The ECUSA calendar seems to indicate that Easter Eve ends
        # Lent *and* begins the Easter season. I'm not sure how. Maybe it's
        # in both? Maybe the daytime is in Lent and the night is in Easter?
    }
    #elsif $easter-point >= 0 && $easter-point <= 49 {
    elsif 0 <= $easter-point <= 49 {
        # yes, this is correct: Pentecost itself is in Easter season;
        # Pentecost season actually begins on the day after Pentecost.
        # Its proper name is "The Season After Pentecost".
        $season = 'Easter';
        $weekno = $easter-point/7;
        $weekno = $weekno.Int;
    }
    #elsif $christmas-point >= $advent-sunday && $christmas-point <= -1 {
    elsif $advent-sunday <= $christmas-point <= -1 {
        $season = 'Advent';
        $weekno = 1+($christmas-point-$advent-sunday)/7;
        $weekno = $weekno.Int;
    }
    #elsif $christmas-point >= 0 && $christmas-point <= 11 {
    elsif 0 <= $christmas-point <= 11 {
        # The Twelve Days of Christmas.
        $season = 'Christmas';
        $weekno = 1+$christmas-point/7;
        $weekno = $weekno.Int;
    }
    #elsif $christmas-point >= 12 && $easter-point <= -47 {
    elsif 12 <= $easter-point <= -47 {
        $season = 'Epiphany';
        $weekno = 1+($christmas-point-12)/7;
        $weekno = $weekno.Int;
    }
    else {
        $season = 'Pentecost';
        $weekno = 1+($easter-point-49)/7;
        $weekno = $weekno.Int;
    }

    # Now, look for feasts.
    my %feasts;
    if $!tradition eq 'ECUSA' {
        %feasts = %feasts-ECUSA;
    }
    elsif $!tradition eq 'UMC' {
        %feasts = %feasts-UMC;
    }
    else {
        die "FATAL: Unknown tradition '$!tradition'";
    }

    my $feast-from-Easter    = %feasts{$easter-point}:exists   ?? %feasts{$easter-point}   !! 0;
    my $feast-from-Christmas = %feasts{10000+100*$m+$d}:exists ?? %feasts{10000+100*$m+$d} !! 0;

    @possibles.push($feast-from-Easter)    if $feast-from-Easter;
    @possibles.push($feast-from-Christmas) if $feast-from-Christmas;

    if $debug and @possibles {
        note "DEBUG: dumping \@possibles array:";
        note @possibles.raku;
    }

    # Maybe transferred from yesterday.
    if not $!transferred { # don't go round infinitely
        my Date $yesterday = self - 1; #$!date - 1;
        my $transferred = Date::Liturgical::Christian.new(
            #%opts, # TODO use same as this?
            $yesterday.year,
            $yesterday.month,
            $yesterday.day,
            transferred => 1,
            #:%opts(%opts), # TODO use same as this?
        );

        if $transferred {
            $transferred.result<name> ~= ' (transferred)';
            #push @possibles, %($transferred.result);
            push @possibles, $transferred.result;
        }
    }

    # Maybe a Sunday.
    @possibles.push({ prec => 5, name => "$season $weekno" })
        if $dow == 7;

    # So, which event takes priority?

    # TODO fix this:
    # sort highest to lowest
    #@possibles = sort { $b->{prec} <=> $a->{prec} } @possibles;
    @possibles = sort { $^b<prec> <=> $^a<prec> }, @possibles;
    if 0 and @possibles {
        note "DEBUG: dumping sorted \@possibles array:";
        note @possibles.raku;
    }

    #if %opts{transferred} {
    if $!transferred {
        # If two feasts coincided today, we were asked to find the one
        # which got transferred.  But Sundays don't get transferred!
        #return undef if @possibles[1] && @possibles[1]<prec> == 5;
        return 0 if @possibles[1] && @possibles[1]<prec> == 5;
        return @possibles[1];
    }

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

}
=end comment

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
