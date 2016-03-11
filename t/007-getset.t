use v6;
use lib 'lib';
use Test;
use Utiaji::Test;
use Utiaji::App::Getset;

my $s = Utiaji::Server.new(app => Utiaji::Getset.new);
my $t = Utiaji::Test.new(server => $s);

$s.start;

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

