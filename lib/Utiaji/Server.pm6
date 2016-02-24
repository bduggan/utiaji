use Utiaji::Server::Grammar;
use Utiaji::Log;

class Utiaji::Server {

    has Promise $.loop is rw;
    has $.timeout = 10;
    has $.port = 3333;
    has $.host = 'localhost';

    method respond($req) {
        my $match = Utiaji::Server::Grammar.parse($req);
        if ($match) {
            trace $match.gist;
        } else {
            trace "did not parse request [[$req]]";
        }
        return "HTTP/1.1 200 OK\n\nhello\n".encode("UTF-8");
    }

    method start {
        $.loop =
        start {
            react {
                whenever IO::Socket::Async.listen($.host,$.port) -> $conn {
                    Promise.in($.timeout).then({ $conn.close });
                    trace "got a connection";
                    my $req_str;
                    whenever $conn.Supply(:bin) -> $buf {
                        trace "got data";
                        if $req_str.defined {
                            try {
                                CATCH { $conn.close; next; }
                                $req_str.append($buf);
                            }
                        } else {
                            $req_str = $buf.clone;
                        }
                        trace "looking for last character";
                        my $last_char = $req_str.subbuf($req_str.elems-1,1);
                        if $last_char.decode('UTF-8') eq "\n" {
                            start {
                                    trace "Got a request.";
                                    my $response = self.respond($req_str.decode('UTF-8'));
                                    $conn.write($response);
                                    $conn.close;
                                    trace "closed connection";
                                }
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
