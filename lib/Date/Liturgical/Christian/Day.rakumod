use Date::Christian::Advent;
use Date::Easter;
use Date::Liturgical::Christian::Feasts;

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
has Hash $.result;
has $.Easter;
has $.martyr;

has $.weekno;
has $.season;
has @.possibles;

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

    =begin comment
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


=begin comment
method color  { self.result<color> // '' }
method name   { self.result<name> // '' }
method season { self.result<season> // '' }
method prec   { self.result<prec> // '' }
=end comment

