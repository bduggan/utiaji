use Test;

use lib 'lib';
use Utiaji::Request;

my $req = parse-request("GET / HTTP/1.1\nHost: localhost\r\n\r\n");
ok $req, "Parsed request";
is $req.WHAT, Utiaji::Request, 'made a request';
is $req.path, '/', 'path';
is $req.method, 'GET', 'req method';
is $req.headers.host, 'localhost', 'host';

$req = parse-request(q:heredoc/END/);
GET / HTTP/1.1
Accept-Encoding: gzip, deflate
Content-Length: 0
Connection: upgrade
Host: echo.jpbd.org
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
X-Forwarded-HTTPS: 0
X-Forwarded-For: 98.115.181.215
Accept-Language: en-US,en;q=0.5

END

ok $req, "parsed firefox request";
is $req.headers.host, 'echo.jpbd.org', 'host';

$req = parse-request(q:heredoc/END/);
GET /chrome HTTP/1.1
Host: echo.jpbd.org
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36
Connection: upgrade
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Encoding: gzip, deflate, sdch
Content-Length: 0
Accept-Language: en-US,en;q=0.8
X-Forwarded-HTTPS: 0
X-Forwarded-For: 98.115.181.215
Upgrade-Insecure-Requests: 1

END

ok $req, "parsed proxy request via nginx";
is $req.headers.host, 'echo.jpbd.org', 'host';

done-testing;
