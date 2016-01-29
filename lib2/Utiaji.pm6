
use HTTP::Server::Async;
use Utiaji::Routes;

class Utiaji {

    has Utiaji::Routes $.routes is rw;

    method BUILD {
        self.routes = Utiaji::Routes.new;
        self.routes.get('/bob',
            sub ($req,$res) {
                $res.headers<Content-Type> = 'text/plain';
                $res.status = 200;
                $res.close('uncle')
            }
        );
    }

    method handler {
        return sub ($request, $response) {
            my $route = self.routes.lookup(
                verb => $request.method,
                path => $request.uri,
            );
            if $route {
                my $cb = $route.code();
                return $cb($request,$response);
            }
            $response.status(404);
            $response.close("Not Found");
        }
    }

    method start($port) {
        my $s = HTTP::Server::Async.new(port => $port);
        $s.handler(self.handler);
        $s.listen;
    }
}
