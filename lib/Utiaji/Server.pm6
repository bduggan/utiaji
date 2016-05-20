use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Handler;
use Utiaji::Response;
use Utiaji::App::Default;
use NativeCall;
sub fork returns int32 is native { * };

# $x in $y --> the elements of $x occur in $y in sequence
sub infix:<in>(Buf[] $x, Buf[] $y) {
    my $e = $x.elems;
    for $y.pairs -> $i {
        next unless $y.elems - $i.key >= $x.elems;
        my @check = $y[ $i.key .. $i.key + $e - 1 ];
        return $i.key if $x.Array eqv @check;
    }
    return Any;
}

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

    method _header_valid(Buf[] $header) {
        debug "in header valid";
        debug $header.perl;
        return ! $header.grep: {
            ( $_ < 32 || $_ >= 127) && $_ != 13 && $_ != 10
        }
    }

    method _header_done(Buf[] $request) {
        my $want = Buf[uint8].new(13,10,13,10);
        my $found = $want in $request;
        fail "bad request" if !$found && !self._header_valid($request);
        fail "bad header" if $found
            && !self._header_valid($request.subbuf(0,$found));
        return $found;
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
        my $done = self._header_done($bytes);
        return $done if $done ~~ Failure;
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
                        :body<houston we have a problem>
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
        my $timeout = Promise.in($.timeout).then({{
            return if $responding;
            debug "timeout, closing connection";
            $conn.close unless $closed;
            $closed = True;
        } });
        trace "got a connection";
        my $started = now;
        my Buf[uint8] $bytes = Buf[uint8].new();
        whenever $conn.Supply(:bin) -> $buf {
            $responding = True;
            my $response = self.handle-request($bytes,$buf);
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
                whenever IO::Socket::Async.listen($.host,$.port) -> $conn {
                    self.handle-connection($conn);
                    QUIT {
                        debug "socket quit";
                    }
                    LAST {
                        debug "socket done";
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
