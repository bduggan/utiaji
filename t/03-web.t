use v6;
use Test;
use Bailador::Test;
use lib 'lib';

use Utiaji;

my $u = Utiaji.new();

ok $u, "Made an app object";

my $r = get-psgi-response('GET', '/');

is $r[0], 200, "Got 200 status code";
is $r[2], "Welcome to Utiaji", "Got content";

done-testing;

