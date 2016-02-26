use Test;

use lib 'lib';
use Utiaji::Request;

my $req = parse-request("GET / HTTP/1.1\nHost: localhost\r\n\r\n");
ok $req, "Parsed request";
is $req.WHAT, Utiaji::Request, 'made a request';
is $req.path, '/', 'path';
is $req.method, 'GET', 'req method';
is $req.headers.host, 'localhost', 'host';

done-testing;
