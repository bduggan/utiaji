use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Handler;
use Utiaji::Response;
use Utiaji::App::Default;
use NativeCall;
sub fork returns int32 is native { * };

class Utiaji::Server does Utiaji::Handler {

    has Promise $.loop;
    has $.timeout = 10;
    has Int $.port = 3333;
    has $.host = 'localhost';
    has $.app is rw = Utiaji::App::Default.new;
    has $.child;

    method url {
        "http://$.host" ~ ($.port == 80 ?? "" !! ":$.port")
    }

    method !header_valid(Blob[] $header) {
        return $header ⊂ (10,13,32..127);
    }

    method !header_done(Buf[] $request) {
        my $found;
        for 0..$request.end - 3 {
            my @these = $request[$_..$_+3];
            next unless @these eqv [13,10,13,10];
            $found = $_;
        }
        return without $found;
        fail "empty header" if $found==0;
        my $head = $request.subbuf(0,$found);
        fail "bad header" unless self!header_valid($head);
        return $head;
    }

    method respond(Str $request) {
        my $req = Utiaji::Request.new(raw => $request);
        $req.parse or do {
            trace "Unhandled request [[$request]]";
            return Utiaji::Response.new(:501status, body => "Not implemented, sorry!");
        };
        return self.handle-request($req,$.app.router);
    }

    method generate-response($bytes is rw,$buf) {
        trace "got buf for request : " ~ $buf.perl;
        $bytes = $bytes ~ $buf;
        trace "all bytes : " ~ $bytes.perl;
        my $done = self!header_done($bytes);
        if !$done.defined and $done.isa(Failure) {
            info $done.exception.message;
            return $done;
        }
        return unless $done;
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
                        :body("houston we have a problem")
                    );
                }
                .resume
            }
        }
        return $response;
    }

    method handle-connection($conn) {
        my $responding = False;
        my $closed = False;
        my $timeout = Promise.in($.timeout).then({
            return if $responding;
            debug "timeout, closing connection";
            $conn.close unless $closed;
            $closed = True;
        });
        trace "got a connection";
        debug "Received request";
        my $started = now;
        my Buf[uint8] $bytes = Buf[uint8].new();
        whenever $conn.Supply(:bin) -> $buf {
            $responding = True;
            my $response = self.generate-response($bytes,$buf);
            if $response ~~ Failure {
                $conn.close;
                $closed = True;
            } elsif $response && !$closed {
                $conn.write($response.to-string.encode("UTF-8"));
                $conn.close;
                $closed = True;
                debug "closed connection";
                debug "elapsed { now - $started }";
            } else {
                $responding = False
            }
            QUIT {
                $closed = True;
                debug "connection quit";
            }
            LAST {
                $closed = True;
                debug "connection done";
            }
        }
    }

    method start {
        info "starting server on { self.url } ";
        $!loop = start {
            react {
                whenever IO::Socket::Async.listen($.host,$.port) {
                    self.handle-connection($^connection);
                    QUIT { debug "socket quit"; }
                    LAST { debug "socket done"; }
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
          sleep 0.2;
          self.start;
          self.await;
          exit;
        }
        $!child = $pid;
        self.ping or error "Failed to start server";
    }

    method ping($timeout = 20) {
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
              info "Waiting for server (sleep 1)";
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
