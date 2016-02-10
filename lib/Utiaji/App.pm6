use HTTP::Server::Async;
use JSON::Fast;
use DBIish;

use Utiaji::Routes;
use Utiaji::Log;

die "Please set PGDATABASE" unless %*ENV<PGDATABASE>;

unit class Utiaji::App;

has Utiaji::Routes $.routes is rw;
has $.db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>);

method handler {
    return sub ($req, $res) {
        my ($route,$matches) = self.routes.lookup(
            verb => $req.method,
            path => $req.uri,
        );
        trace "{$req.method} {$req.uri} ";
        if $route {
            my $cb = $route.code();
            if ($matches.hash.elems) {
                return $cb($req,$res,$matches);
            }
            return $cb($req,$res);
        }
        $res.status = 404;
        $res.headers<Connection> = 'Close';
        $res.write("Not found: { $req.method } { $req.uri }\nAvailable routes :\n");
        for self.routes.routes.flat -> $r {
            $res.write($r.brief);
            $res.write("\n");
        }
        $res.close("Sorry, not found\n");
    }
}

method start($port) {
    # NB: default 8 sec timeout causes errors
    my $s = HTTP::Server::Async.new(port => $port, timeout => 60 * 60 * 24);
    $s.handler(self.handler);
    $s.listen;
}

multi method render($res, :$text!, :$status=200) {
    trace "rendering text";
    $res.headers<Content-Type> = 'text/plain';
    $res.status = $status;
    $res.close('Welcome to Utiaji.')
}

multi method render($res, :$json!, :$status=200) {
    trace "rendering json";
    $res.headers<Content-Type> = 'application/json';
    $res.status = $status;
    $res.close(to-json($json) ~ "\n");
}

multi method render($res, :$status!) {
    # NB, must be declared below the ones above.
    trace "rendering status $status";
    $res.status = $status;
    $res.headers<Content-Type> = 'text/plain';
    $res.close("");
}


