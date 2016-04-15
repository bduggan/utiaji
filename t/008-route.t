use v6;
use lib 'lib';
use Test;
use Uhitaji::Router;

my $r = Uhitaji::Route.new(name => 'hi', verb => 'GET', path => rx{\/there});
is $r.name, 'hi', 'set name';
is $r.verb, 'GET', 'set verb';
#is $r.path, rx{\/there}, 'set path';

my $routes = Uhitaji::Router.new;
$routes.routes.push($r);

$routes.routes.push(
    Uhitaji::Route.new(:name<ho>, :verb<GET>, path => rx{^ \/here $})
);

$routes.routes.push(
    Uhitaji::Route.new(
        :name<findme>,
        :verb<GET>,
        path => rx{^ \/findme $},
        code => sub {
            return "found it";
        } )
);

is $routes.routes[0].name, 'hi', 'added a route';
is $routes.routes[1].name, 'ho', 'added a route';

$routes.routes.push(
    Uhitaji::Route.new(
        :name<patternroute>,
        :verb<GET>,
        path => rx{^ \/with\/pattern\d $},
        code => sub {
            return "found pattern";
        } )
);

$routes.routes.push(
    Uhitaji::Route.new(
        :name<top>,
        :verb<GET>,
        path => rx{^ \/ $})
);

my ($found,$m) = $routes.lookup(path => '/findme', verb => 'GET');
ok $found, "Found route";
is $found.name, 'findme', 'lookup by path';
is $found.code()(), "found it", "ran route code";

($found,$m) = $routes.lookup(
    path => "/with/pattern9",
    verb => "GET"
);

ok $found, "Found pattern";
is $found.name, "patternroute", "Found right pattern";

done-testing;
