use lib 'lib';
use Test;
use Utiaji::App;
use Utiaji::Test;

class Hello is Utiaji::App { }

my $app = Hello.new;

$app.router.get('/', sub ($req,$res) { $app.render: $res, text => "hello" } );

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/').status-is(200).content-is('hello');

$t.stop;

done-testing;


