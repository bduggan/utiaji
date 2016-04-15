use lib 'lib';
use Test;
use Uhitaji::App;
use Uhitaji::Test;

class Hello is Uhitaji::App { }

my $app = Hello.new;

$app.router.get('/', sub ($req,$res) { $app.render: $res, text => "hello" } );

my $t = Uhitaji::Test.new.start($app);

$t.get-ok('/').status-is(200).content-is('hello');

$t.stop;

done-testing;


