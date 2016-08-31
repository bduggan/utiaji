use lib 'lib';
use Test;
use Utiaji::App;
use Utiaji::Test;

class Hello is Utiaji::App { }
my $app = Hello.new;
{
  use Utiaji::Wacha;
  set-router($app.router);

  get / { text => "hello, world" };
  get /greet { text => "hola" };

};

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/').status-is(200).content-is('hello, world');

$t.get-ok('/greet').status-is(200).content-is('hola');

$t.stop;

done-testing;


