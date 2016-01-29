use Test;

use lib 'lib2';

use Utiaji::Routes;

my $r = Utiaji::Route.new(name => 'hi', verb => 'GET', path => '/there');
is $r.name, 'hi', 'set name';
is $r.verb, 'GET', 'set verb';
is $r.path, '/there', 'set path';

my $routes = Utiaji::Routes.new;
$routes.routes.push($r);

$routes.routes.push(
    Utiaji::Route.new(:name<ho>, :verb<GET>, :path</here>)
);

$routes.routes.push(
    Utiaji::Route.new(:name<findme>, :verb<GET>, :path</findme>, code => sub {
        return "found it";
    } )
);

is $routes.routes[0].name, 'hi', 'added a route';
is $routes.routes[1].name, 'ho', 'added a route';

my $found = $routes.lookup(path => '/findme', verb => 'GET');
ok $found, "Found route";
is $found.name, 'findme', 'lookup by path';
is $found.code()(), "found it", "ran route code";

