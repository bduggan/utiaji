use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

# setup:
# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

unit class Utiaji::Getset is Utiaji::App;

has $.db = Utiaji::DB.new;

method BUILD {

    given self.routes {
        .get('/',
            sub ($req,$res) {
                self.render: $res, text => 'Welcome to Utiaji.'
            }
        );

        .get('/get/_key',
            sub ($req,$res,$/) {
                $.db.query: "select v from kv where k=?", $<key>
                    or return self.render: $res, :404status;
                my $json = $.db.json or return self.render: $res, :404status;
                self.render: $res, :$json
            }
        );

        .post('/set/_key',
            sub ($req,$res,$/) {
                trace "running POST /set/_key";
                my $json = $req.json;
                my $key = $<key>;
                unless $json {
                    return self.render: $res, :400status,
                        json => { status => "fail",
                                  reason => "missing or invalid json" }
                }
                $.db.query(q[insert into kv (k,v) values (?, ?)], $key, :$json)
                    or return self.render: $res,
                        json => { status => "fail", reason => $.db.errors },
                        status => 409;
                trace "rendering ok";
                self.render: $res, json => { status => 'ok' }
            }
        );

        .post('/del/_key',
            sub ($req,$res,$/) {
                my $json = $req.json;
                $.db.query: "delete from kv where k = ?", $<key>
                    or return self.render: $res, :400status,
                       json => { status => "fail", reason => $.db.errors };

                return self.render: $res, json => { status => 'ok' }
            }
        );

    }
}
