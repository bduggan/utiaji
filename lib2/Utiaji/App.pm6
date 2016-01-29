use HTTP::Server::Async;
use Utiaji::Routes;

class Utiaji::App {

    has Utiaji::Routes $.routes is rw;

    method handler {
        return sub ($req, $res) {
            my $route = self.routes.lookup(
                verb => $req.method,
                path => $req.uri,
            );
            if $route {
                my $cb = $route.code();
                return $cb($req,$res);
            }
            $res.status(404);
            $res.close("Not Found");
        }
    }

    method start($port) {
        my $s = HTTP::Server::Async.new(port => $port);
        $s.handler(self.handler);
        $s.listen;
    }
}
