use Test;

use lib 'lib';
use Utiaji::Request::Parser;

for dir 'requests/in' -> $file {
    my $in = $file.slurp;
    my $out;
    ok $req = parse-request $file, "parsed $file";
    is $req.WHAT, Utiaji::Request, 'made a request';
    ok $req.method, "got a method";
    ok $req.path, "got a path";
    ok $req.host, "got a host";
    ok $req.headers, "got a headers object";
    is $req.content-length, $req.body.chars;
    my $out = file "requests/out/$file";
    is-deeply $req.gist, $out, "got structure";
}

done-testing;
