use v6;
use lib 'lib';
use Test;
use Utiaji::Test;

my $t = Utiaji::Test.new;

$t.server.start;
$t.get_ok('/')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is('Welcome to Utiaji.');

$t.get_ok("/no/such/url")
  .status_is(404);

done-testing;
