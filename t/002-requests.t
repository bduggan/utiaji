use v6;
use lib 'lib';
use Test;
use Utiaji::Request;

for dir 't/requests/in' -> $file {
    my $in = $file.slurp;
    my $req = Utiaji::Request.new(raw => $in);
    ok $req.parse, "parsed $file";
    is $req.WHAT, Utiaji::Request, 'made a request';
    ok $req.verb, "got a method";
    ok $req.path, "got a path";
    ok $req.headers, "got a headers object";
    ok $req.headers.host, "got a host";
    #is $req.headers.content-length, $req.body.raw.chars;
    #my $out = file "requests/out/$file";
    #is-deeply $req.gist, $out, "got structure";
}

done-testing;
