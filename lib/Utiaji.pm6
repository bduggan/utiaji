use Utiaji::App;
use JSON::Fast;

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
                $res.headers<Content-Type> = 'application/json';
                $res.status = 200;
                $res.close(to-json({ status => 'ok' } ));
            }
        )
    }
}
}
