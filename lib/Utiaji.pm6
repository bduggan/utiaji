use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

my $db = Utiaji::DB.new;

# setup:
# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

class Utiaji is Utiaji::App {
method BUILD {

    my regex piece { <-[ / ]>+ };

    self.routes = Utiaji::Routes.new;
    # Routing table.
    given (self.routes) {
        .get(rx{^ \/ $},
            sub ($req,$res) {
                self.render: $res, text => 'Welcome to Utiaji.'
            }
        );

        .get(rx{^ \/get\/<key=piece> $},
            sub ($req,$res,$m) {
                $db.query: "select v from kv where k=?", $m<key>
                    or return self.render: $res, :404status;
                my $json = $db.json or return self.render: $res, :404status;
                self.render: $res, :$json
            }
        );

        .post(rx{^ \/set\/<key=piece> $},
            sub ($req,$res,$m,$json) {
                my $key = $m<key>;
                unless $json {
                    return self.render: $res, :400status,
                        json => { status => "fail",
                                  reason => "missing or invalid json" }
                }
                $db.query(q[insert into kv (k,v) values (?, ?)], $key, :$json)
                    or return self.render: $res,
                        json => { status => "fail", reason => $db.errors },
                        status => 409;
                trace "rendering ok";
                self.render: $res, json => { status => 'ok' }
            }
        );

        .post(rx{^ \/del\/<key=piece> $},
            sub ($req,$res,$m,$json) {
                $db.query: "delete from kv where k = ?", $m<key>
                    or return self.render: $res, :400status,
                       json => { status => "fail", reason => $db.errors };

                return self.render: $res, json => { status => 'ok' }
            }
        );

    }
}
}
