unit module Utiaji::Handler;

use Utiaji::Dispatcher;
use Utiaji::Response;
use Utiaji::Router;
use Utiaji::Log;

sub handle-request(Utiaji::Request $request,Utiaji::Router $router) is export {
    debug $request.gist;
    my ($route,$captures) =
        $router.lookup(
            verb => $request.verb,
            path => $request.path);

    unless $route {
        trace "Not found";
        my $response = Utiaji::Response.new(:404status, :body<not found>);
        debug $response.status-line;
        return $response;
    }
    trace "Matched { $route.gist } ";
    my $response = Utiaji::Response.new;
    dispatch-request($route, $captures, $request, $response);
    debug $response.status-line;
    return $response;
}

