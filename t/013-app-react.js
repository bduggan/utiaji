use lib 'lib';
use Test;
use Utiaji::App::React;
use Utiaji::Test;

my $t = Utiaji::Test.new.start( Utiaji::App::React.new );

$t.get-ok('/cal').status-is(200);

$t.get-ok('/today').status-is(200)
  .json-is({events => [«eat drink "be merry"»]});

$t.get-ok('/tomorrow').status-is(200)
  .json-is({events => ["we die"]});

$t.get-ok('/react.js').status-is(200);

$t.stop;

done-testing;

