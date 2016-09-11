use lib 'lib';
use lib 't/tlib';
use tlib;
use Test;
use Utiaji::App::Pim;
use Utiaji::Test;

clear-db;

my $app = Utiaji::App::Pim.new;

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/cal').status-is(200).content-like( rx/utiaji/);

# $t.post-ok('/cal', json => { data => { '2010-02-03' => "something" } })
#    .status-is(200)
#    .json-is({status => 'ok'});
#
# $t.get-ok("/cal/range/2010-02-03/2010-02-03")
#    .status-is(200)
#    .json-is({'2010-02-03' => 'something'});
#
# $t.post-ok('/wiki/testpage', json => { txt => 'abc' })
#    .status-is(200)
#    .json-is({status => 'ok'});
#
# $t.get-ok("/wiki/testpage")
#    .status-is(200)
#    .content-like( rx/abc/ );
#
# $t.get-ok("/wiki/testpage.json")
#    .status-is(200)
#    .json-is({:name<testpage>, :txt<abc>, dates => [], files => [], pages => []});
#
# $t.post-ok('/cal', json => { data => { '2010-02-04' => 'a @link or @two' } })
#   .status-is(200)
#   .json-is({status => 'ok'});
#
# $t.get-ok("/wiki/link.json").status-is(200)
#    .json-is({:name<link>, :txt(''), dates => [ '2010-02-04' ], :files([]), pages => [] });
#
# $t.get-ok("/wiki/two.json").status-is(200)
#     .json-is({:name<two>, :txt(''), dates => [ '2010-02-04' ], :files([]), pages => [] });
#
# $t.post-ok('/search', json => { txt => 'abc' }).status-is(200)
#     .json-is([ { label => "testpage", href => '/wiki/testpage' }, ]);
#
# $t.post-ok('/search', json => { txt => 'testpage' }).status-is(200)
#     .json-is([ { label => "testpage", href => '/wiki/testpage' }, ]);
#
# $t.post-ok('/wiki/beer', json => { txt => '🍺' }).status-is(200)
#      .json-is( { status => "ok" } );
#
# $t.get-ok('/wiki/beer.json').status-is(200)
#     .json-is( { name => "beer", :dates($[]), :files([]), :pages($[]), txt => '🍺' } );
#
# $t.post-ok('/wiki/face', json => { txt => '😀' }).status-is(200)
#     .json-is( { status => "ok" } );
#
# $t.get-ok('/wiki/face.json').status-is(200)
#     .json-is( { name => "face", :dates($[]), :files([]), :pages($[]), txt => '😀' } );
#
$t.stop;

done-testing;

