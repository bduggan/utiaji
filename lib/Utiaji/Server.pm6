use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Handler;
use Utiaji::Response;
use Utiaji::App::Default;
use NativeCall;
sub fork returns int32 is native { * };

class Utiaji::Server {

    has Promise $.loop;
    has $.timeout = 10;
    has Int $.port = 3333;
    has $.host = 'localhost';
    has $.app is rw = Utiaji::App::Default.new;
    has $.child;

    method url {
        "http://$.host" ~ ($.port == 80 ?? "" !! ":$.port")
    }

    method _header_done(Buf[] $request) {
        $request.decode('UTF-8').contains("\r\n\r\n");
    }

    method respond(Str $request) {
        my $req = Utiaji::Request.new(raw => $request).parse or do {
            warn "did not parse request [[$request]]";
            return Utiaji::Response.new(status => 500);
        }
        return handle-request($req,$.app.routes);
    }

    method start {
        info "starting server on { self.url } ";
        $!loop =
        start {
            react {
                whenever IO::Socket::Async.listen($.host,$.port) -> $conn {
                    my $promise = Promise.in($.timeout).then({{
                        return unless $conn.Supply.live;
                        error "timeout, closing connection";
                        $conn.close;
                    } });
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

    method start-fork {
        my $pid;
        unless ($pid = fork) {
          self.start;
          self.await;
          exit;
        }
        $!child = $pid;
    }

    method stop-fork {
        if $!child {
            say "# killing $!child";
            shell "kill $!child"
        }
    }
}
