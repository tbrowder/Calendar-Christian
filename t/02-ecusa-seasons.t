use Test;
use Date::Liturgical::Christian;
use Text::Utils :strip-comment;

plan 365;

my $ifil = "./t/data/2006-ecusa.data";

my $n = 0;
for $ifil.IO.lines -> $line is copy {
    ++$n;

    $line = strip-comment $line;
    next if $line !~~ /\S/;

    #last if $n > 10;
    #last if $n > 5;

    #my $name = substr $line, 32;
    #$line = substr $line, 0, 32;

    my @w = $line.words;
    my ($date, $color, $season) = @w[0..2];
    my $name = @w.elems > 3 ?? @w[3..*].join(' ') !! '';

    #note "DEBUG: '$date', '$color', '$season', '$name'"; #die "DEBUG exit";
    #next; # DEBUG

    my ($y, $m, $d) = split /'-'/, $date;
    $m ~~ s/^0//;
    $d ~~ s/^0//;

    #note "DEBUG: '$y', '$m', '$d'"; #die "DEBUG exit";
    #next; # DEBUG

    my $dt = Date::Liturgical::Christian.new(
        year => $y,
        month => $m,
        day => $d,
        tradition => 'ECUSA',
    );

    is $dt.season, $season, "$date season '$season'";
}
