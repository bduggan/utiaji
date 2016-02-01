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
        .get('/',
            sub ($req,$res) {
                $res.headers<Content-Type> = 'text/plain';
                $res.status = 200;
                $res.close('Welcome to Utiaji.')
            }
        );

        .get(rx{^ \/get\/<key=piece> $},
            sub ($req,$res,$m) {
                my $sth = self.db.prepare(
                        q[select v from kv where k=?]);
                $sth.execute($m<key>);
                my $json = $sth.row;
                $res.headers<Content-Type> = 'application/json';
                $res.status = 200;
                $res.close("$json\n");
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
                    $json = from-json($req.data.decode('UTF-8').chop)
                }
                if ($errors) {
                     $res.status = 400;
                     $res.headers<Content-Type> = 'application/json';
                     $res.close(to-json(
                          { status => "fail",
                            reason => $errors,
                          }));
                     return;
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
                     $res.status = 400;
                     $res.headers<Content-Type> = 'application/json';
                     $res.close(to-json(
                          { status => "fail",
                            reason => $errors,
                          }));
                     return;
                }

                $res.headers<Content-Type> = 'application/json';
                $res.status = 200;
                $res.close(to-json({ status => 'ok' } ));
            }
        )


    }
}
}
