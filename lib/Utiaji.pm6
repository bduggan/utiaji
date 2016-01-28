use Bailador;
use JSON::Fast;
use DBIish;

my $db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>);

# createdb utiaji
# psql utiaji -c "create table kv(k varchar not null primary key, v jsonb)"

class Utiaji {

    get '/' => sub {
        "Welcome to Utiaji"
    }

    get '/get/:key' => sub ($key) {
        my $sth = $db.prepare(q[select v from kv where k=?]);
        $sth.execute($key);
        my $json = $sth.row;
        header("Content-Type", "application/json");
        return $json ~ "\n";
    }

    post '/del/:key' => sub ($key) {
        my $sth = $db.prepare(q[delete from kv where k=?]);
        $sth.execute($key);
        my $json = $sth.row;
        header("Content-Type", "application/json");
        return '{"status":"ok"}';
    }


    post '/set/:key' => sub ($key) {
        my $json =
            try {
                CATCH {
                    default {
                        warn "Error parsing JSON: $_";
                        return "Error parsing JSON."
                    }
                }
                from-json(request.body)
            }
        my $sth = $db.prepare(q[insert into kv (k,v) values (?, ?)]);
        $sth.execute($key, to-json($json));
        header("Content-Type", "application/json");
        return '{"status":"ok"}';
    }

    method run {
        baile;
    }
}
