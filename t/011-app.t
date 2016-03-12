use lib 'lib';
use Test;
use Utiaji::App;
use Utiaji::Test;

class Hello is Utiaji::App { }

my $app = Hello.new;

$app.routes.get('/', sub ($req,$res) { $app.render: $res, text => "hello" } );

my $t = Utiaji::Test.new.start_server($app);

$t.get_ok('/').status_is(200).content_is('hello');

done-testing;


