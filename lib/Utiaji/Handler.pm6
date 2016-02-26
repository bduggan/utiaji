
unit module Utiaji::Handler;

use Utiaji::Response;

sub handle-request($request) is export {
    my $res = Utiaji::Response.new(:200status, :body<hello>);
    $res.prepare-response;
    return $res;
}

