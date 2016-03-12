use v6;
use lib 'lib';
use Test;
use Utiaji::Test;
use Utiaji::App::Getset;

my $s = Utiaji::Server.new(app => Utiaji::Getset.new);
my $t = Utiaji::Test.new(server => $s);

$s.start;

$t.post-ok("/set/foo", json => { abc => 123 } )
  .status-is(200)
  .json-is( { status => 'ok' } );

$t.post-ok("/set/foo", json => { something => 'else' } )
  .status-is(409)
  .content-type-is('application/json');

$t.get-ok("/get/foo")
  .status-is(200)
  .json-is({abc => 123});

$t.post-ok("/del/foo").status-is(200);

$t.get-ok("/get/foo").status-is(404);

$t.post-ok("/set/badfoo",
    headers => { "content-type" => "application/json" },
    content => 'not va ---( lid JSON ')
  .status-is(400);

done-testing;

