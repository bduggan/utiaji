use v6;
use lib 'lib';
use Test;
use Utiaji::Test;

my $t = Utiaji::Test.new;

$t.server.start-fork;
$t.get-ok('/')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('Welcome to Utiaji.');

$t.get-ok("/no/such/url")
  .status-is(404);

$t.server.stop-fork;

done-testing;
