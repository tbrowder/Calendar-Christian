use Date::Christian::Advent;
use Date::Easter;
use Date::Liturgical::Christian::Feasts;
use Date::Liturgical::Christian::Feast;

unit class Date::Liturgical::Christian::Day is Date;
# a child class of Date

my $debug = 0;

multi method new($year, $month, $day,
                 :$tradition!,
                 :$advent-blue!,
                 :$bvm-blue!,
                 :$rose!,
                 :$yesterday, # true if called as yesterday
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

# other attrs
has $.Easter;
has $.martyr;

has $.weekno;
has $.season;
has @.possibles;
# for debugging
has $.easter-point;
has $.christmas-point;
has $.advent-sunday; # this is days before Christmas expressed as a negative number!


submethod TWEAK {
    my $y    = self.year;
    my $m    = self.month;
    my $d    = self.day;
    # my $days = Date_to_Days($y, $m, $d);
    my $days = date2days self;
    my $dow  = self.day-of-week;

    $!Easter = Easter($y);

    my @possibles;

    # "The Church Year consists of two cycles of feasts and holy days:
    #  one is dependent upon the movable date of the Sunday of the
    #  Resurrection or Easter Day; the other, upon the fixed date of
    #  December 25, the Feast of our Lord's Nativity or Christmas
    #  Day."

    # my $easter = Date_to_Days($y, Date_Easter($y));

    $!easter-point  = $days - date2days($!Easter);
    $!advent-sunday = Advent-Sunday($y).day-of-year - Date.new($y, 12, 25).day-of-year;;

    # We will store the amount of time until (-ve) or since (+ve)
    # Christmas in $christmas-point. Let's make the cut-off date the
    # end of February, since we'll be dealing with Easter-based dates
    # after that, it avoids the problems of considering leap years.

=begin comment
  if ($m>2) {
      $christmas_point = $days - Date_to_Days($y, 12, 25);
  } else {
      $christmas_point = $days - Date_to_Days($y-1, 12, 25);
  }
=end comment

    if $m > 2 {
        $!christmas-point = $days - date2days($y, 12, 25);
    }
    else {
        $!christmas-point = $days - date2days($y-1, 12, 25);
    }

    # First, figure out the season.
    my $season;
    my $weekno;

    # 1
    if -47 < $!easter-point < 0 {
        $season = 'Lent';
        $weekno = ($!easter-point + 50) div 7;
        # FIXME: The ECUSA calendar seems to indicate that Easter Eve ends
        # Lent *and* begins the Easter season. I'm not sure how. Maybe it's
        # in both? Maybe the daytime is in Lent and the night is in Easter?
    }
    # 2
    elsif 0 <= $!easter-point <= 49 {
        # yes, this is correct: Pentecost itself is in Easter season;
        # Pentecost season actually begins on the day after Pentecost.
        # Its proper name is "The Season After Pentecost".
        $season = 'Easter';
        $weekno = $!easter-point div 7;
    }
    # 3
    elsif $!advent-sunday <= $!christmas-point <= -1 {
        $season = 'Advent';
        $weekno = 1 + ($!christmas-point - $!advent-sunday) div 7;
    }
    # 4
    elsif 0 <= $!christmas-point <= 11 {
        # The Twelve Days of Christmas.
        $season = 'Christmas';
        $weekno = 1 + $!christmas-point div 7;
    }
    # 5
    elsif $!christmas-point >= 12 && $!easter-point <= -47 {
        $season = 'Epiphany';
        $weekno = 1 + ($!christmas-point - 12) div 7;
    }
    # 6
    else {
        $season = 'Pentecost';
        $weekno = 1 + ($!easter-point - 49) div 7;
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

    my $eidx = $!easter-point;
    my $cidx = 10000+100*$m+$d;
    my $feast-from-Easter    = %feasts{$eidx}:exists ?? %feasts{$eidx} !! 0;
    my $feast-from-Christmas = %feasts{$cidx}:exists ?? %feasts{$cidx} !! 0;

    my ($ffe, $ffc);
    if $feast-from-Easter {
        $ffe = Date::Liturgical::Christian::Feast.new: :index($eidx),
               :name(%feasts{$eidx}<name>), :prec(%feasts{$eidx}<prec>);
    }
    if $feast-from-Christmas {
        $ffc = Date::Liturgical::Christian::Feast.new: :index($cidx),
               :name(%feasts{$cidx}<name>), :prec(%feasts{$cidx}<prec>);
    }
    if $ffc and $ffe and $debug {
        note "DEBUG: Two feasts on the same day: '{$ffe.raku}' and '{$ffc.raku}'.";
    }

    @possibles.push($ffe) if $feast-from-Easter;
    @possibles.push($ffc) if $feast-from-Christmas;

    if $debug and @possibles {
        note "DEBUG: dumping \@possibles array:";
        note @possibles.raku;
    }

    # There is only one feast per day for each of Christmas and Easter references.
    # However, there may be one of each occuring on the same day, so one
    # will get transferred to the next day: the one with the lowest precedence.
    # Note Sundays are never transferred.

    =begin comment
      # my ($yestery, $yesterm, $yesterd) = Add_Delta_Days(1, 1, 1, $days-2);
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
    =end comment

    # Maybe a Sunday.
    if $dow == 7 {
        my $fs = Date::Liturgical::Christian::Feast.new: # :index($cidx),
                 :name("$season $weekno"), :prec(5);
        @possibles.push($fs);
        #@possibles.push({ prec => 5, name => "$season $weekno" })
    }

    # So, which event takes priority?

    # TODO fix this:
    # sort highest to lowest
    #@possibles = sort { $b->{prec} <=> $a->{prec} } @possibles;
    #@possibles = sort { $^b<prec> <=> $^a<prec> }, @possibles;
    @possibles = sort { $^b.prec <=> $^a.prec }, @possibles;
    if 0 and @possibles {
        note "DEBUG: dumping sorted \@possibles array:";
        note @possibles.raku;
    }

    =begin comment
    #if %opts{transferred} {
    if $!transferred {
        # If two feasts coincided today, we were asked to find the one
        # which got transferred.  But Sundays don't get transferred!
        #return undef if @possibles[1] && @possibles[1]<prec> == 5;
        return 0 if @possibles[1] && @possibles[1]<prec> == 5;
        return @possibles[1];
    }
    =end comment

    $!season    = $season;
    $!weekno    = $weekno;
    @!possibles = @possibles;
}

multi sub date2days(Date $d) is export {
    date2days $d.year, $d.month, $d.day
}

multi sub date2days($year, $month, $day) is export {
    # calc days from 1,1,1 AD
    my $d0 = Date.new(1, 1, 1);
    Date.new($year, $month, $day).daycount - $d0.daycount + 1
}

sub days2date($days --> Date) is export {
    my $d0 = Date.new: 1, 1, 1;
    $d0 + $days - 1
}

=begin comment
method color  { self.result<color> // '' }
method name   { self.result<name> // '' }
method season { self.result<season> // '' }
method prec   { self.result<prec> // '' }
=end comment
