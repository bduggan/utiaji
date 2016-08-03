use v6;
use lib 'lib';
use Test;

use Utiaji::Session;

my $s = Utiaji::Session.new(key => '123');
ok $s, "made a session object";
$s<foo> = 'bar';
is $s<foo>, 'bar', "get foo and it was bar";

my $t = Utiaji::Session.new(key => '123');
$t.parse(~$s);
is $t<foo>, 'bar', "froze and then parsed";

done-testing;
