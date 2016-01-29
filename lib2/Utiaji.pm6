
use HTTP::Server::Async;

class Utiaji {
    method handler {
        return sub ($request, $response) {
            $response.headers<Content-Type> = 'text/plain';
            $response.status = 200;
            if ($request.uri eq '/bob') {
                $response.write("uncle");
                $response.close;
                return;
            }
            $response.write("Hello ");
            $response.close("world!");
        }
    }

    method start($port) {
        my $s = HTTP::Server::Async.new(port => $port);
        $s.handler(self.handler);
        $s.listen;
    }
}
