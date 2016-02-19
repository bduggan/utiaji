use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

my $db = Utiaji::DB.new;

# setup:
# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

unit class Utiaji is Utiaji::App;

method BUILD {

    given self.routes {
        .get('/',
            sub ($req,$res) {
                self.render: $res, text => 'Welcome to Utiaji.'
            }
        );

        .get('/get/_key',
            sub ($req,$res,$m) {
                $db.query: "select v from kv where k=?", $m<key>
                    or return self.render: $res, :404status;
                my $json = $db.json or return self.render: $res, :404status;
                self.render: $res, :$json
            }
        );

        .post('/set/_key',
            sub ($req,$res,$m,$json) {
                trace "running POST /set/_key";
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

        .post('/del/_key',
            sub ($req,$res,$m,$json) {
                $db.query: "delete from kv where k = ?", $m<key>
                    or return self.render: $res, :400status,
                       json => { status => "fail", reason => $db.errors };

                return self.render: $res, json => { status => 'ok' }
            }
        );

    }
}
