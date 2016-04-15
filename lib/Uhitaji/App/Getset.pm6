use Uhitaji::App;
use Uhitaji::DB;
use Uhitaji::Log;

# setup:
# createdb uhitaji
# psql uhitaji -c "create table kv(k varchar not null primary key, v jsonb)"

unit class Uhitaji::App::Getset is Uhitaji::App;

has $.db = Uhitaji::DB.new;

method BUILD {

    given self.router {
        .get('/',
            sub ($req,$res) {
                self.render: $res, text => 'Welcome to Uhitaji.'
            }
        );

        .get('/get/∙key',
            sub ($req,$res,$/) {
                $.db.query: "select v::text from kv where k=?", $<key>
                    or return self.render: $res, :404status;
                my $json = $.db.json or return self.render: $res, :404status;
                self.render: $res, :$json
            }
        );

        .post('/set/∙key',
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

        .post('/del/∙key',
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
