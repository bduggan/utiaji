use Test;

use lib 'lib';
use Utiaji::Request;

my $str = "GET / HTTP/1.1\nHost: localhost\n\n";

my $req = Utiaji::Request.new(raw => $str);
ok $req.parse, "parsed request";
ok $req, "Parsed GET request";
is $req.WHAT, Utiaji::Request, 'made a request';
is $req.path, '/', 'path';
is $req.verb, 'GET', 'verb';
is $req.headers.host, 'localhost', 'host';

done-testing;
