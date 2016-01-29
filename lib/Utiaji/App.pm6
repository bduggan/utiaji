use HTTP::Server::Async;
use Utiaji::Routes;
use DBIish;

die "Please set PGDATABASE" unless %*ENV<PGDATABASE>;

class Utiaji::App {

    has Utiaji::Routes $.routes is rw;
    has $.db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>);

    method handler {
        return sub ($req, $res) {
            my ($route,$matches)
             = self.routes.lookup(
                verb => $req.method,
                path => $req.uri,
            );
            if $route {
                my $cb = $route.code();
                return $cb($req,$res,$matches);
            }
            $res.status = 404;
            $res.headers<Connection> = 'Close';
            $res.close("Sorry, not found\n");
        }
    }

    method start($port) {
        # NB: default 8 sec timeout causes errors
        my $s = HTTP::Server::Async.new(port => $port, timeout => 60 * 60 * 24);
        $s.handler(self.handler);
        $s.listen;
    }
}
