use v6;
use lib 'lib';
use Test;
use Utiaji::Test;
use Utiaji::Server;

my $s = Utiaji::Server.new;
my $t = Utiaji::Test.new;

$s.start;

$t.get-ok('/')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("Welcome to Utiaji.");

$t.get-ok('/test')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is("This is a test of the emergency broadcast system.");

$t.post-ok("/echo", json => { abc => 123 } )
  .status-is(200)
  .json_is( { abc => 123 } );

$t.get-ok('/placeholder/bob')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('bob');

done-testing;

