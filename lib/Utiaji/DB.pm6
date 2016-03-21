unit class Utiaji::DB;

use Utiaji::Log;
use DBIish;
use JSON::Fast;

has $.db is rw;
has $.sth is rw;
has $.errors is rw;
has @.results is rw;

method BUILD {
    die "Please set PGDATABASE" unless %*ENV<PGDATABASE>;
    $.db = DBIish.connect("Pg", database => %*ENV<PGDATABASE>, :!RaiseError);
}

multi method query($sql, $key, :$json!) {
    my $arg = to-json($json);
    self.query($sql,$key,$arg);
}

multi method query($sql is copy,*@bind) {
    trace "Query: $sql";
    trace "Bind: @bind" if @bind;
    $.sth = self.db.prepare($sql);
    @.results = Mu;
    try {
        CATCH {
            default {
                False;
            }
        }
        $.sth.execute(|@bind)
     } or do {
        $.errors = $.sth.errstr;
        debug "Error: $.errors";
        return False;
    };
    @.results = ();
    while $.sth.fetch -> $row {
        @.results.push($row);
    }
    return True;
}

method result {
    return @.results unless @.results==1;
    return @.results[0] unless @.results[0]==1;
    return @.results[0][0];
}

method json {
    return unless $.result;
    return from-json($.result);

}
