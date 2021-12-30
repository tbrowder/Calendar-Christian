use Storable::Lite;

unit class Date::Liturgical::Christian is Date does FileStore;
# a child class of Date

use Date::Liturgical::Christian::Feasts;

# use a class attribute to define a file in which to keep 
# a copy of the serialized class (to-file, from-file)
my $dir = %*ENV<HOME> // '.';
my $xfer-store = $dir ~ '/' ~ '.date-liturgical-christian'; 
method xfer-store { $xfer-store }

my $debug = 0;

multi method new(:%opts!) { #, |c) {
    # Convert the input values to a Date object. Following code thanks
    # to @lizmat on IRC #raku, 2021-11-18, 06:08
    # (and on IRC #raku, 2021-03-29, 11:50)
    self.Date::new(%opts<year>, %opts<month>, %opts<day>); #, |c);
}

multi method new($year, $month, $day, :%opts, :$transferred) { # , |c) {
    # Convert the input values to a Date object. Following code thanks
    # to @lizmat on IRC #raku, 2021-11-18, 06:08
    # (and on IRC #raku, 2021-03-29, 11:50)
    self.Date::new($year, $month, $day, :%opts, :$transferred); # |c);
}

# constructor options
has $.tradition   = 'ECUSA'; # Episcopal Church USA
#has $.tradition   = 'UMC'; # United Methodist Church

has Hash $.result is rw;

has Date $!Easter;

has $.transferred = 0;

has $.advent-blue = 0;
has $.bvm-blue    = 0;
has $.rose        = 0;

=begin comment
has $.color  = '';
has $.season = '';
has $.name   is rw = '';
has $.bvm    = '';
has $.martyr = '';
=end comment

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

    #=begin comment
    # Maybe transferred from yesterday.
    #unless %opts{transferred} { # don't go round infinitely
    unless $!transferred { # don't go round infinitely
        #my ($yestery, $yesterm, $yesterd) = Add_Delta_Days(1, 1, 1, $days-2);
        my ($yestery, $yesterm, $yesterd);
        my Date $yesterday = self - 1; #$!date - 1;
        my $transferred = Date::Liturgical::Christian.new(
            #%opts, # TODO use same as this?
            year => $yesterday.year,
            month => $yesterday.month,
            day => $yesterday.day,
            transferred => 1,
            :%opts, # TODO use same as this?
        );

        if $transferred {
            $transferred.result<name> ~= ' (transferred)';
            #push @possibles, %($transferred.result);
            push @possibles, $transferred.result;
        }
    }
    #=end comment

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

    #=begin comment
    #if %opts{transferred} {
    if $!transferred {
        # If two feasts coincided today, we were asked to find the one
        # which got transferred.  But Sundays don't get transferred!
        #return undef if @possibles[1] && @possibles[1]<prec> == 5;
        return 0 if @possibles[1] && @possibles[1]<prec> == 5;
        return @possibles[1];
    }
    #=end comment

    #my $result = ${dclone(\($possibles[0]))};
    # TODO if @possibles[0] is a persistent class, restore its result
    $!result = @possibles[0];

    unless $!result {
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
            when $k eq 'transferred' { $!transferred = $v }

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
}

method color  { self.result<color> // '' }
method name   { self.result<name> // '' }
method season { self.result<season> // '' }
method prec   { self.result<prec> // '' }

# This returns the date Easter occurs on for a given year as a Date
# object.  Coded directly from the Calender FAQ
# (https://tondering.dk/claus/calendar.html)
# Easter in the Gregorian calendar
sub Easter(Int \year --> Date) is export {
    my \G = year mod 19;
    my \C = year div 100;
    my \H = (C - (C div 4) - (8*C + 13) div 25 + 19*G + 15) mod 30;
    my \I = H - (H div 28) * (1 - (29 div (H + 1)) * (21 - G) div 11);
    my \J = (year + year div 4 + I + 2 - C + C div 4) mod 7;
    my \L = I - J;
    my \EasterMonth = 3 + (L + 40) div 44;
    my \EasterDay = L + 28 - 31 * (EasterMonth div 4);
    Date.new(year, EasterMonth, EasterDay)
}

sub Advent-Sunday3($y --> Date) is export {
    # Method 3: Find the 4th Sunday before
    # Christmas, not counting the Sunday
    # which may be Christmas.
    # Note this is the method attempted by
    # the Perl author but it was wrong as
    # noted in the bug report on the CPAN site.
    my $d = Date.new($y, 12, 25); # Christmas
    my $dow = $d.day-of-week;
    if $dow == 7 {
        # Christmas is on Sunday, count 28 days back.
        return $d - 28
    }
    else {
        # find prev Sunday, count 21 days back from that
        # sun mon tue wed thu fri sat sun
        #  7   1   2   3   4   5   6   7
        #  0   1   2   3  -3  -2  -1   0
        return $d - $dow - 21
    }
}

sub Advent-Sunday2($y --> Date) is export {
    # Method 2: Find the Sunday following the
    # last Thursday in November.
    # Source: Malcolm Heath <malcolm@indeterminate.net>
    my $d = Date.new($y, 11, 30); # last day of November
    my $dow = $d.day-of-week;
    note "DEBUG start: dow = $dow" if $debug;
    while $dow != 4 {
        $d -= 1;
        $dow = $d.day-of-week;
        note "DEBUG: dow = $dow" if $debug;
    }
    # found last Thursday in November
    # following Sunday is 3 days hence
    $d += 3
}

sub Advent-Sunday($y --> Date) is export {
    # Method 1: Find the Sunday closest to November 30
    # (The Feast of St. Andrew). If November 30 is a Sunday,
    # St. Andrew gets moved.
    # Source: Malcolm Heath <malcolm@indeterminate.net>
    my $fsa = Date.new($y, 11, 30);
    my $fsa-dow = $fsa.day-of-week; # 1..7 (Mon..Sun)
    # sun mon tue wed thu fri sat sun
    #  7   1   2   3   4   5   6   7
    #  0   1   2   3  -3  -2  -1   0
    if $fsa-dow == 7 {
        # bingo!
        return $fsa
    }
    elsif $fsa-dow < 4 {
        # closest to previous Sunday
        return $fsa - $fsa-dow
    }
    else {
        # closest to following Sunday
        return $fsa + (7 - $fsa-dow)
    }
}

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
