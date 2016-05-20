use lib 'lib';
use Test;
use Utiaji::App::Pim;
use Utiaji::Test;

my $app = Utiaji::App::Pim.new;

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/cal').status-is(200).content-like( rx/utiaji/);

$t.post-ok('/cal', json => { data => { '2010-02-03' => "something" } })
  .status-is(200)
  .json-is({status => 'ok'});

$t.get-ok("/cal/range/2010-02-03/2010-02-03")
  .status-is(200)
  .json-is({'2010-02-03' => 'something'});

$t.post-ok('/wiki/testpage', json => { txt => 'abc' })
  .status-is(200)
  .json-is({status => 'ok'});

$t.get-ok("/wiki/testpage")
  .status-is(200)
  .content-like( rx/abc/ );

$t.stop;

done-testing;

