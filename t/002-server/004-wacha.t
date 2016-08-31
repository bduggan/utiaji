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
};

my $t = Utiaji::Test.new.start($app);
$t.get-ok('/').status-is(200).content-is('hello, world');
$t.stop;

done-testing;


