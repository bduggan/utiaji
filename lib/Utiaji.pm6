use Utiaji::App;
use JSON::Fast;
use DBIish;

my $db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>);
# setup:
# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

class Utiaji is Utiaji::App {
method BUILD {

    my regex piece { <-[ / ]>+ };

    self.routes = Utiaji::Routes.new;
    given (self.routes) {

        # Routing table.
        .get(rx{^ \/ $},
            sub ($req,$res) {
                self.render($res, text => 'Welcome to Utiaji.');
            }
        );

        .get(rx{^ \/get\/<key=piece> $},
            sub ($req,$res,$m) {
                my $sth = self.db.prepare(
                        q[select v from kv where k=?]);
                $sth.execute($m<key>);
                my $json = $sth.row
                    or do { $res.status = 404;
                            $res.close;
                            return;
                        };
                $json = from-json($json);
                self.render($res, json => $json);
            }
        );

        .post(rx{^ \/set\/<key=piece> $},
            sub ($req,$res,$m) {
                my $key = $m<key>;
                my $json;
                my $errors;
                try {
                    CATCH {
                        # TODO, logging
                        #say "error: " ~ .message;
                        $errors = .message;
                        .resume
                    }
                    # chop removes trailling \0
                    $json = from-json($req.data.decode('UTF-8').chop);
                }
                if ($errors or !$json) {
                     return self.render( $res,
                         status => 400,
                         json =>
                          { status => "fail",
                            reason => $errors // "Could not parse" }
                     );
                }

                $errors = "";
                try {
                    CATCH {
                        $errors = .message;
                        .resume
                    }
                    my $sth = $db.prepare(q[insert into kv (k,v) values (?, ?)]);
                    $sth.execute($key, to-json($json));
                }
                if ($errors) {
                    return self.render($res,
                        status => 409,
                        json => { status => "fail", reason => $errors, });
                }

                self.render($res, json => { status => 'ok' } );
            }
        );

        .post(rx{^ \/del\/<key=piece> $},
            sub ($req,$res,$m) {
                my $errors;
                my $key = $m<key>;
                $errors = "";
                try {
                    CATCH {
                        $errors = .message;
                        .resume
                    }
                    my $sth = $db.prepare(q[delete from kv where k = ?]);
                    $sth.execute($key);
                }
                if ($errors) {
                    return self.render($res,
                        status => 400,
                        json => { status => "fail", reason => $errors, });
                }

                return self.render($res, json => { status => 'ok' });
            }
        );

    }
}
}
