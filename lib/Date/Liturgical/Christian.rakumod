
unit class Date::Liturgical::Christian is Date;
# a child class of Date

use Date::Liturgical::Christian::Constants :feasts;

multi method new($year, $month, $day, |c) {
    # Convert the input values to a Date object. Following code thanks
    # to @lizmat on IRC #raku, 2021-11-18, 06:08
    # (and on IRC #raku, 2021-03-29, 11:50)
    self.Date::new($year, $month, $day, |c);
}

# constructor options
has $.tradition   = 'ECUSA'; # Episcopal Church USA
has $.advent-blue = 0;
has $.bvm-blue    = 0;
has $.rose        = 0;

has Date $!Easter;

has $.color  = '';
has $.season = '';
has $.name   = '';
has $.bvm    = '';

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
    my $weekno;

    my $advent-sunday = Advent-Sunday($y).day-of-year;

    #if $easter-point > -47 && $easter-point < 0 {
    if  -47 < $easter-point < 0 {
        $!season = 'Lent';
        $weekno = ($easter-point+50)/7;
        # FIXME: The ECUSA calendar seems to indicate that Easter Eve ends
        # Lent *and* begins the Easter season. I'm not sure how. Maybe it's
        # in both? Maybe the daytime is in Lent and the night is in Easter?
    }
    #elsif $easter-point >= 0 && $easter-point <= 49 {
    elsif 0 <= $easter-point <= 49 {
        # yes, this is correct: Pentecost itself is in Easter season;
        # Pentecost season actually begins on the day after Pentecost.
        # Its proper name is "The Season After Pentecost".
        $!season = 'Easter';
        $weekno = $easter-point/7;
    }
    #elsif $christmas-point >= $advent-sunday && $christmas-point <= -1 {
    elsif $advent-sunday <= $christmas-point <= -1 {
        $!season = 'Advent';
        $weekno = 1+($christmas-point-$advent-sunday)/7;
    }
    #elsif $christmas-point >= 0 && $christmas-point <= 11 {
    elsif 0 <= $christmas-point <= 11 {
        # The Twelve Days of Christmas.
        $!season = 'Christmas';
        $weekno = 1+$christmas-point/7;
    }
    #elsif $christmas-point >= 12 && $easter-point <= -47 {
    elsif 12 <= $easter-point <= -47 {
        $!season = 'Epiphany';
        $weekno = 1+($christmas-point-12)/7;
    }
    else {
        $!season = 'Pentecost';
        $weekno = 1+($easter-point-49)/7;
    }

    # Now, look for feasts.

    my $feast-from-Easter    = %feasts{$easter-point}:exists ?? %feasts{$easter-point} !! 0;
    my $feast-from-Christmas = %feasts{10000+100*$m+$d}:exists ?? %feasts{10000+100*$m+$d} !! 0;

    @possibles.push($feast-from-Easter) if $feast-from-Easter;
    @possibles.push($feast-from-Christmas) if $feast-from-Christmas;

    if 0 and @possibles {
        note "DEBUG: dumping \@possibles array:";
        note @possibles.raku;
    }

    =begin comment
    # Maybe transferred from yesterday.
    unless %opts{transferred} { # don't go round infinitely
        my ($yestery, $yesterm, $yesterd) = Add_Delta_Days(1, 1, 1, $days-2);
        my $transferred = $class->new(
            %opts,
            year => $yestery,
            month => $yesterm,
            day => $yesterd,
            transferred=>1,
        );

        if $transferred {
            $transferred->{name} .= ' (transferred)';
            push @possibles, $transferred;
        }
    }
    =end comment

    # Maybe a Sunday.
    @possibles.push({ prec=>5, name=>"$!season $weekno" })
        #if Day_of_Week($y, $m, $d)==7;
        if $dow == 7;


    # So, which event takes priority?

    #@possibles = sort { $b->{prec} <=> $a->{prec} } @possibles;
    
    # TODO fix this:
    # sort highest to lowest
    #@possibles = sort { $b->{prec} <=> $a->{prec} } @possibles;

    =begin comment
    if %opts{transferred} {
        # If two feasts coincided today, we were asked to find the one
        # which got transferred.  But Sundays don't get transferred!
        return undef if @possibles[1] && @possibles[1]->{prec}==5;
        return @possibles[1];
    }
    =end comment

    #my $result = ${dclone(\($possibles[0]))};
    my $result = @possibles[0];

    $result = { name=>'', prec=>1 } unless $result;
    # TODO fix this:
    #$result = { %opts, %$result, season=>$!season, weekno=>$weekno };
    $result<season> = $!season;
    $result<weekno> = $weekno;

    #if %opts{rose} {
    if $!rose {
        my %rose-days = [ 'Advent 2' => 1, 'Lent 3' => 1 ];
        #$result->{colour} = 'rose' if %rose_days{$result->{name}};
        $result<color> = 'rose' if %rose-days{$result<name>:exists} and %rose-days{$result<name>};
    }

    # TODO fix this
    if !defined $result<color> {
        if $result<prec> > 2 && $result<prec> != 5 {
            # feasts are generally white,
            # unless marked differently.
            # But martyrs are red, and Marian
            # feasts *might* be blue.
            if $result<martyr> {
                $result<colour> = 'red';
            }
            elsif $!bvm-blue && $result<bvm> {
                $result<color> = 'blue';
            }
            else {
                $result<color> = 'white';
            }
        }
        else {
            # Not a feast day.
            if $!season eq 'Lent' {
                $result<color> = 'purple';
            }
            elsif $!season eq 'Advent' {
                if $!advent-blue {
                    $result<color> = 'blue';
                }
                else {
                    $result<color> = 'purple';
                }
            }
            else {
                # The great fallback:
                $result<color> = 'green';
            }
        }
    }

    # Two special cases for Christmas-based festivals which depend on
    # the day of the week.

    if $result<prec> == 5 { # An ordinary Sunday
        if $christmas-point == $advent-sunday {
            $result<name> = 'Advent Sunday';
            $result<color> = 'white';
        }
        elsif $christmas-point == $advent-sunday -7 {
            $result<name> = 'Christ the King';
            $result<color> = 'white';
        }
    }

    if  0 {
        note "DEBUG: dumping var \$result hash:";
        #note $result.raku;
        note %($result).raku;
    }

    for %($result).kv -> $k, $v {
        note "DEBUG: result key '$k' => '$v'"
    }
}


# This returns the date easter occurs on for a given year as a Date
# object).  This is from the Calendar FAQ.  Taken from Date::Manip.
sub Easter($y --> Date) {
    my $c = $y/100;
    my $g = $y % 19;
    my $k = ($c-17)/25;
    my $i = ($c - $c/4 - ($c-$k)/3 + 19*$g + 15) % 30;
    $i     = $i - ($i/28)*(1 - ($i/28)*(29/($i+1))*((21-$g)/11));
    my $j = ($y + $y/4 + $i + 2 - $c + $c/4) % 7;
    my $l = $i-$j;
    my $m = 3 + ($l+40)/44;
    my $d = $l + 28 - 31*($m/4);
    Date.new($y, $m, $d)
}

sub Advent-Sunday($y --> Date) {
    my $Christmas-Day = Date.new($y,12,25);
    my $cd = $Christmas-Day;
    # the original is marked as erroneous in an issue
    #return -(Day_of_Week($y,12,25) + 4*7);

    my $cdow = $cd.day-of-week;
    # Advent Sunday is the 4th Sunday before Christmas
    my $days-before = $cdow + 4*7;
    $cd.earlier(:day($days-before));
}
