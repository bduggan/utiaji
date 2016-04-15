use v6;
use lib 'lib';
use Test;
use Uhitaji::Test;
use Uhitaji::Server;

my $s = Uhitaji::Server.new;
my $t = Uhitaji::Test.new;

$s.start-fork;

$t.get-ok('/')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("Welcome to Uhitaji.");

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

