use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Handler;
use Utiaji::Response;

class Utiaji::Server {

    has Promise $.loop is rw;
    has $.timeout = 10;
    has $.port = 3333;
    has $.host = 'localhost';

    method _header_done(Buf[] $request) {
        # NB: won't work if body is later
        $request.subbuf($request.elems-4,4) eq "\r\n\r\n".encode('UTF-8');
    }

    method respond($req) {
        trace "generating request object";
        my $request = parse-request($req) or
            trace "did not parse request [[$req]]";
        my $response = handle-request($request);
        return $response.to-string.encode("UTF-8");
    }

    method start {
        debug "starting server on http://{$.host}:{$.port}";
        $.loop =
        start {
            react {
                whenever IO::Socket::Async.listen($.host,$.port) -> $conn {
                    #Promise.in($.timeout).then({ try {
                    #    trace "timeout, closing connection";
                    #   $conn.close if $conn;
                    #} });
                    trace "got a connection";
                    my Buf[uint8] $request = Buf[uint8].new();
                    whenever $conn.Supply(:bin) -> $buf {
                        trace "got bytes for request";
                        $request = $request ~ $buf;
                        if self._header_done($request) {
                            trace "Got a request header.";
                            my $response = self.respond($request.decode('UTF-8'));
                            $conn.write($response);
                            $conn.close;
                            trace "closed connection";
                        }
                    }
                }
            }
        }
    }

    method await {
        await $.loop;
    }
}
