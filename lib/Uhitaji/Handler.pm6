unit module Uhitaji::Handler;

use Uhitaji::Dispatcher;
use Uhitaji::Response;
use Uhitaji::Router;
use Uhitaji::Log;

sub handle-request(Uhitaji::Request $request,Uhitaji::Router $router) is export {
    debug $request.gist;
    my ($route,$captures) =
        $router.lookup(
            verb => $request.verb,
            path => $request.path);

    unless $route {
        trace "Not found";
        my $response = Uhitaji::Response.new(:404status, :body<not found>);
        debug $response.status-line;
        return $response;
    }
    trace "Matched { $route.gist } ";
    my $response = Uhitaji::Response.new;
    dispatch-request($route, $captures, $request, $response);
    debug $response.status-line;
    return $response;
}

