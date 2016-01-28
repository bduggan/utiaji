use v6;
use Test;
use Bailador;
use Bailador::Test;
use JSON::Fast;

use lib 'lib';

use Utiaji;

my $u = Utiaji.new();

my $r;
my $json;

$r = get-psgi-response('POST', '/del/this');
$json = from-json($r[2]);
is-deeply $json, { "status" => "ok" }, "deleted this";

$r = get-psgi-response('POST', '/set/this', '{"that":12}');
$json = from-json($r[2]);
is-deeply $json, { "status" => "ok" }, "POST to key";

$r = get-psgi-response('GET', '/get/this');
$json = from-json($r[2]);
is-deeply $json, { "that" => 12 }, "Got key back";

$r = get-psgi-response('POST', '/del/this');
$json = from-json($r[2]);
is-deeply $json, { "status" => "ok" }, "deleted again";

done-testing;

