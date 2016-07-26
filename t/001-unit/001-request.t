use v6;
use lib 'lib';
use Test;
use Utiaji::Request;

{
    my $str = "GET / HTTP/1.1\nHost: localhost\n\n";
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    ok $req, "Parsed GET request";
    is $req.WHAT, Utiaji::Request, 'made a request';
    is $req.path, '/', 'path';
    is $req.verb, 'GET', 'verb';
    is $req.headers<host>, 'localhost', 'host';
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
        Content-Type:application/json
        Content-Length:10

        {"a":"2"}
        DONE
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    is $req.path, '/set', 'path';
    is $req.body.raw, q[{"a":"2"}] ~ "\n", 'body';
    is $req.headers<content-type>, 'application/json', 'parsed type';
    is $req.headers<content-length>, 10, 'parsed length';
}

{
    my $str = q:to/DONE/;
        GET /foo?bar=baz&buz=123&flubber=99&flubber=123 HTTP/1.1
        Host: localhost

        DONE
    my $req = Utiaji::Request.new(raw => $str);
    ok $req.parse, "parsed request";
    is $req.path, '/foo', 'path';
    is $req.query, 'bar=baz&buz=123&flubber=99&flubber=123', 'query';
    is $req.query-params<bar>, 'baz', 'query param';
    is $req.query-params<buz>, 123, 'query param';
    is-deeply $req.query-params<flubber>, [ '99', '123'], 'multi query param';
}


done-testing;
