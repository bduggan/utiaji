unit module Hamna::Handler;

use Hamna::Dispatcher;
use Hamna::Response;
use Hamna::Router;
use Hamna::Log;

sub handle-request(Hamna::Request $request,Hamna::Router $router) is export {
    debug $request.gist;
    my ($route,$captures) =
        $router.lookup(
            verb => $request.verb,
            path => $request.path);

    unless $route {
        trace "Not found";
        my $response = Hamna::Response.new(:404status, :body<not found>);
        debug $response.status-line;
        return $response;
    }
    trace "Matched { $route.gist } ";
    my $response = Hamna::Response.new;
    dispatch-request($route, $captures, $request, $response);
    debug $response.status-line;
    return $response;
}

