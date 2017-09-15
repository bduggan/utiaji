use v6;
use lib 'lib';
use Test;

BEGIN { %*ENV<UTIAJI_SECRET> = '123'; }
use Utiaji::Session;

my $s = Utiaji::Session.new(key => '123');
ok $s, "made a session object";
$s<foo> = 'bar';
is $s<foo>, 'bar', "get foo and it was bar";
my $stringified = ~$s;
ok $stringified ~~ Str, "stringified";

my $t = Utiaji::Session.new(key => '123');
$t.parse($stringified);
is $t<foo>, 'bar', "roundtrip";

my $u = Utiaji::Session.new(key => '456');
ok !$u.parse($stringified), "failed with wrong key";

done-testing;
