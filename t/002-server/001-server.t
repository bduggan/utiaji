use v6;
use lib 'lib';
use Test;
use Utiaji::Test;
use Utiaji::Server;

my $s = Utiaji::Server.new;
my $t = Utiaji::Test.new;

$s.start-fork;

$t.get-ok('/')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("Welcome to Utiaji.");

$t.post-ok("/echo", json => { abc => 123 } )
  .status-is(200)
  .json-is( { abc => 123 } );

$t.get-ok('/greet/bob')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('hi, bob');

$s.stop-fork;

done-testing;

