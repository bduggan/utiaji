use lib 'lib';
use Test;

use Utiaji::Router;
use Wacha;

my $router = Utiaji::Router.new;

set-router($router);

get / "Hello, world";

get /hi { "hi there" };

get /greet/:name -> $/ { "greetings, $<name>" };

/wewe "no verb";

ok 1, 'parsed dsl';

is $router.routes.elems, 4, "added routes";

is $router.routes[0].pattern, '/', 'first one is /';

is $router.routes[1].pattern, '/hi', 'second is /hi';

is $router.routes[2].pattern, '/greet/:name', 'third is /greet/:name';

is $router.routes[2].code.signature.arity, 1, 'code takes 1 arg';

is $router.routes[3].pattern, '/wewe', 'route with no verb';

my $code = $router.routes[3].code;

is $code(), "no verb", "route with no block returns string";

done-testing;
