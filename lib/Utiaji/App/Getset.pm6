use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;
use Utiaji::Error;

# setup:
# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

unit class Utiaji::App::Getset is Utiaji::App;

sub db { state $db //= Utiaji::DB.new; }

submethod BUILD {

    given self.router {
        .get('/',
            sub ($req) {
                text => 'Welcome to Utiaji.'
            }
        );

        .get('/get/∙key',
            sub ($/,$req) {
                db.query: "select v::text from kv where k=?", $<key>
                    or return :404status;
                my $json = db.json or return :404status;
                return :$json
            }
        );

        .post('/set/∙key',
            sub ($/,Utiaji::Request $req) {
                trace "running POST /set/_key";
                my $json = $req.json;
                my $key = $<key>;
                fail bad-request("missing json",:json) unless $json;
                db.query(q[insert into kv (k,v) values (?, ?)], $key, :$json)
                    or fail bad-request(db.errors,:json,:409status);
                trace "rendering ok";
                return json => { status => 'ok' }
            }
        );

        .post('/del/∙key',
            sub ($/,$req) {
                db.query: "delete from kv where k = ?", $<key>
                    or return :400status,
                       json => { status => "fail", reason => db.errors };
                return json => { status => 'ok' }
            }
        );

    }
}
