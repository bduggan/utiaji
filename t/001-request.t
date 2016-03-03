use Test;

use lib 'lib';
use Utiaji::Request;

{
    my $str = "GET / HTTP/1.1\nHost: localhost\n\n";
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    ok $req, "Parsed GET request";
    is $req.WHAT, Utiaji::Request, 'made a request';
    is $req.path, '/', 'path';
    is $req.verb, 'GET', 'verb';
    is $req.headers.host, 'localhost', 'host';
}

{
    my $str = "GET /foo HTTP/1.1\r\nHost: localhost\r\n\r\n";
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    is $req.path, '/foo', 'path';
}

{
    my $str = q:to/DONE/;
    GET /foo HTTP/1.1
    Host: localhost

    DONE
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    is $req.path, '/foo', 'path';
}

{
    my $str = q:to/DONE/;
        POST /set HTTP/1.1
        Host: localhost
        Content-type:application/json
        Content-length:10

        {"a":"2"}
        DONE
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    is $req.path, '/set', 'path';
    is $req.body.raw, q[{"a":"2"}] ~ "\n", 'body';
    is $req.headers.content-type, 'application/json', 'parsed type';
    is $req.headers.content-length, 10, 'parsed length';
}

done-testing;
