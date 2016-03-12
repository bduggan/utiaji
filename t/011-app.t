use lib 'lib';
use Test;
use Utiaji::App;
use Utiaji::Test;

class Hello is Utiaji::App { }

my $app = Hello.new;

$app.routes.get('/', sub ($req,$res) { $app.render: $res, text => "hello" } );

my $s = Utiaji::Server.new(app => $app);
my $t = Utiaji::Test.new(server => $s);

$s.start;

$t.get_ok('/').status_is(200).content_is('hello');

done-testing;


