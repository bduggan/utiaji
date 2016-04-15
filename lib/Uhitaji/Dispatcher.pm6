#| Dispatch HTTP requests.
unit module Uhitaji::Dispatcher;

use Uhitaji::Request;
use Uhitaji::Log;
use Uhitaji::Response;

sub dispatch-request($route,
    Match $captures,
    Uhitaji::Request $req,
    Uhitaji::Response $res is rw
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
