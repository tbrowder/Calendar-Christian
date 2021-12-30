#!/usr/bin/env raku

use Storable::Lite;

class Foo does FileStore {
    my $store-file = "store-file.txt";
    has $.a is rw = '';
    method store-file { $store-file }
}

my $o = Foo.new;
$o.a = "first";

say "store file = '{Foo.store-file}'";
$o.to-file: Foo.store-file;

my $o2 = Foo.from-file: Foo.store-file;
say $o2.raku;
say $o2.a;
$o2.a = "second";
$o2.to-file: Foo.store-file;

$o = Foo.from-file: Foo.store-file;
say $o.a;

