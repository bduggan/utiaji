
unit module Utiaji::Handler;

use Utiaji::Response;
use Utiaji::Routes;
use Utiaji::Log;

sub handle-request($request,$routes) is export {
    debug $request.gist;
    my $route = $routes.lookup(
        verb => $request.method,
        path => $request.path);
    #unless $found {
    #     return Utiaji::Response.new(:404status, :body<are you lost?>);
    #}
    if ($route) {
        trace "Matched { $route.gist } ";
    } else {
        trace "Not found";
    }
    my $res = Utiaji::Response.new(:200status, :body<hello>);
    $res.prepare-response;
    return $res;
}

