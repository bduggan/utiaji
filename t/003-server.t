use v6;
use lib 'lib';
use Test;
use Hamna::Test;
use Hamna::Server;

my $s = Hamna::Server.new;
my $t = Hamna::Test.new;

$s.start-fork;

$t.get-ok('/')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("Welcome to Hamna.");

$t.get-ok('/test')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("This is a test of the emergency broadcast system.");

$t.post-ok("/echo", json => { abc => 123 } )
  .status-is(200)
  .json-is( { abc => 123 } );

$t.get-ok('/placeholder/bob')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('bob');

$s.stop-fork;

done-testing;

