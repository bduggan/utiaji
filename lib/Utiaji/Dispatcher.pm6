unit module Utiaji::Dispatcher;
use Utiaji::Request;
use Utiaji::Response;

sub dispatch-request($route, $captures, Utiaji::Request $req,Utiaji::Response $res is rw) is export {
    $res.status = 200;
    $res.body = 'hello';

   my $cb = $route.code;
   $cb($req,$res);
}
