#| Dispatch HTTP requests.
unit module Hamna::Dispatcher;

use Hamna::Request;
use Hamna::Log;
use Hamna::Response;

sub dispatch-request($route,
    Match $captures,
    Hamna::Request $req,
    Hamna::Response $res is rw
) is export {
    $res.status = 200;
    $res.body = "";

   my $cb = $route.code;
   if $captures && $captures.hash.elems {
       trace "Dispatching to callback with captures.";
       $cb($req,$res, $captures);
   } else {
       trace "Dispatching to callback without captures.";
       $cb($req,$res);
   }
}
