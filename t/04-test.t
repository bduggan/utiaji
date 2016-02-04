#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Utiaji;
use Utiaji::Test;

my $t = Utiaji::Test.new;

$t.start_server;
$t.get_ok('/')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is('Welcome to Utiaji.');

$t.get_ok("/no/such/url")
  .status_is(404);

$t.post_ok("/set/foo", json => { abc => 123 } )
  .status_is(200)
  .json_is( { status => 'ok' } );

$t.post_ok("/set/foo", json => { something => 'else' } )
  .status_is(409)
  .content_type_is('application/json');

$t.get_ok("/get/foo")
  .status_is(200)
  .json_is({abc => 123});

$t.post_ok("/del/foo").status_is(200);

$t.get_ok("/get/foo").status_is(404);

$t.post_ok("/set/badfoo",
    headers => { "content-type" => "application/json" },
    content => 'not va ---( lid JSON ')
  .status_is(400);

done-testing;

