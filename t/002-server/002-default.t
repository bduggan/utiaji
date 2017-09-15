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

$t.get-ok('/hello')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('is it me');

$t.get-ok('/you-are')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('looking for');

$t.get-ok('/greet/björk')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('hi, björk');

$t.get-ok('/hola/reindeer?from=nørsk')
  .status-is(200)
  .content-type-is('text/plain')
  .content-is('Hi, reindeer from nørsk');

$t.get-ok('/fail').status-is(400);

$t.get-ok('/look')
  .status-is(200)
  .json-is({answer => 42});

$t.post-ok('/echo', json => { 'hi' => 'there' })
   .status-is(200)
   .json-is({'hi' => 'there'});

$t.get-ok('/count')
  .status-is(200)
  .content-like(rx{1});

$t.server.stop-fork;

done-testing;
