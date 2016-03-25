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
        return handle-request($req,$.app.router);
    }

    method handle-request($bytes is rw,$buf) {
        trace "got bytes for request";
        $bytes = $bytes ~ $buf;
        return unless self._header_done($bytes);
        trace "Got a request header.";
        my $response;
        try {
            $response = self.respond($bytes.decode('UTF-8'));
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
        return $response;
    }

    method handle-connection($conn) {
        my $responded = False;
        my $promise = Promise.in($.timeout).then({{
            return if $responded;
            error "timeout, closing connection";
            $conn.close;
        } });
        trace "got a connection";
        my Buf[uint8] $bytes = Buf[uint8].new();
        whenever $conn.Supply(:bin) -> $buf {
            if my $response = self.handle-request($bytes,$buf) {
                $conn.write($response.to-string.encode("UTF-8"));
                $conn.close;
                $responded = True;
                trace "closed connection";
            }
        }
    }

    method start {
        info "starting server on { self.url } ";
        $!loop = start {
            react {
                whenever IO::Socket::Async.listen($.host,$.port) -> $conn {
                    self.handle-connection($conn);
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
        self.ping or error "Failed to start server";
    }

    method ping($timeout = 10) {
        my $p = Promise.in($timeout);
        my $conn;
        while (!$p.status) {
            $conn = try {
                CATCH {
                  default {
                    $conn = Nil;
                  }
                }
                IO::Socket::INET.new(host => $.host, port => $.port);
            }
            last if $conn;
            NEXT {
              trace "Waiting for server (sleep 1)";
              sleep 1;
            }
        }
        if $conn {
            $conn.close;
            return True;
        }
        error "ping failed";
        return False;
    }

    method stop-fork {
        if $!child {
            trace "killing $!child";
            shell "kill $!child"
        }
    }
}
