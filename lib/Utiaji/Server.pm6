use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Handler;
use Utiaji::Response;
use Utiaji::App::Default;

class Utiaji::Server {

    has Promise $.loop is rw;
    has $.timeout = 10;
    has Int $.port = 3333;
    has $.host = 'localhost';
    has $.app is rw = Utiaji::App::Default.new;

    method _header_done(Buf[] $request) {
        # NB: won't work if body is later
        $request.subbuf($request.elems-4,4) eq "\r\n\r\n".encode('UTF-8');
    }

    method respond(Str $request) {
        my $req = parse-request($request) or do {
            warn "did not parse request [[$request]]";
            return HTTP::Response.new(status => 500);
        }
        return handle-request($req,$.app.routes);
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
                    my Buf[uint8] $request_bytes = Buf[uint8].new();
                    whenever $conn.Supply(:bin) -> $buf {
                        trace "got bytes for request";
                        $request_bytes = $request_bytes ~ $buf;
                        if self._header_done($request_bytes) {
                            trace "Got a request header.";
                            my $response;
                            try {
                                $response = self.respond($request_bytes.decode('UTF-8'));
                                CATCH {
                                    default {
                                        my $error = $_;
                                        error "caught { $error.gist }";
                                        $response = Utiaji::Response.new(
                                            :500status,
                                            :body<houston we have a problem>
                                        );
                                    }
                                    .resume
                                }
                            }
                            $conn.write($response.to-string.encode("UTF-8"));
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
