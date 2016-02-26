use JSON::Fast;
use DBIish;

use Utiaji::Routes;
use Utiaji::Log;

die "Please set PGDATABASE" unless %*ENV<PGDATABASE>;

unit class Utiaji::App;

has Utiaji::Routes $.routes = Utiaji::Routes.new;
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
            my $content_type = $req.headers<Content-type>;
            if ($content_type and $content_type eq 'application/json') {
                trace "Got JSON";
                my $json;
                # TODO simplify, also log parse errors
                try { $json = from-json($req.data.decode('UTF-8').chop); };
                if ($matches.hash.elems) {
                    return $cb($req,$res,$matches.hash,$json);
                }
                return $cb($req,$res,$json);
            }
            if ($matches.hash.elems) {
                return $cb($req,$res,$matches.hash);
            }
            return $cb($req,$res);
        }
        $res.status = 404;
        $res.headers<Connection> = 'Close';
        $res.write("Not found: { $req.method } { $req.uri }\nAvailable routes :\n");
        for self.routes.routes.flat -> $r {
            $res.write($r.gist);
            $res.write("\n");
        }
        $res.close("Sorry, not found\n");
    }
}

multi method render($res, :$text!, :$status=200) {
    trace "rendering text";
    $res.headers.content-type = 'text/plain';
    $res.body = $text;
    $res.status = $status;
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


