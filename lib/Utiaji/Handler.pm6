
unit module Utiaji::Handler;

use Utiaji::Response;

sub handle-request($request) is export {
    my $res = Utiaji::Response.new;
    $res.status = 200;
    $res.body = 'hello';
    $res.headers.content-type = 'text/plain';
    return $res;
}

