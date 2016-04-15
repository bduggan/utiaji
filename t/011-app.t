use lib 'lib';
use Test;
use Hamna::App;
use Hamna::Test;

class Hello is Hamna::App { }

my $app = Hello.new;

$app.router.get('/', sub ($req,$res) { $app.render: $res, text => "hello" } );

my $t = Hamna::Test.new.start($app);

$t.get-ok('/').status-is(200).content-is('hello');

$t.stop;

done-testing;


