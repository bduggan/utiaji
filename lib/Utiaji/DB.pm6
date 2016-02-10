unit class Utiaji::DB;

use DBIish;
use JSON::Fast;

has $.db is rw;
has $.sth is rw;
has $.errors is rw;
has $.results is rw;

method BUILD {
    $.db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>);
}

multi method query($sql, $key, :$json!) {
    my $arg = to-json($json);
    self.query($sql,$key,$arg);
}

multi method query($sql,*@bind) {
    $.sth = self.db.prepare($sql);
    try {
        CATCH {
            $.errors = .message;
            self.results = Mu;
            return False;
        }
        $.sth.execute(|@bind);
    }
    self.results = $.sth.allrows;
    return True;
}

method result {
    return $.results[0][0];
}

method json {
    return unless $.result;
    return from-json($.result);

}
