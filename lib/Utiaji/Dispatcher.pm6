#| Dispatch HTTP requests.
unit role Utiaji::Dispatcher;

use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Response;

method dispatch-request($route,
    Match $captures,
    Utiaji::Request $req,
    Utiaji::Response $res is rw
) is export {
    $res.status = 200;
    $res.body = "";

   my $cb = $route.code;
   if $captures && $captures.hash.elems {
       trace "Dispatching to callback with captures.";
       $cb.signature.count == 2 ?? $cb($res, $captures) !! $cb($req, $res, $captures);
   } else {
       trace "Dispatching to callback without captures.";
       $cb.signature.count == 1 ?? $cb($res) !! $cb($req,$res);
   }
}
