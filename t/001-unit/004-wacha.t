use lib 'lib';
use Test;

use Utiaji::Router;
use Utiaji::Wacha;

my $router = Utiaji::Router.new;

set-router($router);

get / "Hello, world";

get /hi { "hi there" };

get /greet/:name { "greetings, $<name>" };

ok 1, 'parsed dsl';

is $router.routes.elems, 3, "added routes";

is $router.routes[0].pattern, '/', 'first one is /';

is $router.routes[1].pattern, '/hi', 'second is /hi';

is $router.routes[2].pattern, '/greet/:name', 'third is /greet/:name';

done-testing;
