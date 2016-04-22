#| Dispatch HTTP requests.
unit module Utiaji::Dispatcher;

use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Response;

sub dispatch-request($route,
    Match $captures,
    Utiaji::Request $req,
    Utiaji::Response $res is rw
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
