use lib 'lib';
use Test;
use Utiaji::App;
use Utiaji::Test;

class Hello is Utiaji::App { }
my $app = Hello.new;
{
  use Wacha;
  set-router($app.router);

  /yo { text => "oy" }

  get / { text => "hello, world" };

  get /greet { :text<hola> };

  get /ciao/:name -> $/ { text => "hi, $<name>" }

  /jambo 'sana';

};

my $t = Utiaji::Test.new.start($app);

$t.get-ok('/yo').status-is(200).content-is('oy');

$t.get-ok('/').status-is(200).content-is('hello, world');

$t.get-ok('/greet').status-is(200).content-is('hola');

$t.get-ok('/ciao/friend').status-is(200).content-is('hi, friend');

$t.get-ok('/jambo').status-is(200).content-is('sana');

$t.stop;

done-testing;


