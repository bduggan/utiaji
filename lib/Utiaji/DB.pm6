#| Utiaji::DB provides a layer of abstraction around a postgres database.
unit class Utiaji::DB;

use Utiaji::Log;
use DBIish;
use DBDish::Pg;
use JSON::Fast;

my $db;

has DBDish::Pg::Connection $.db is rw; #= Database handle.
has $.sth is rw;       #= Most recent statement handle.
has $.errors is rw;    #= Most recent errors.
has @.results is rw;   #= Most recent result set.

sub decode-json($x) {
   return Nil unless $x.defined;
   return Nil if $x eq '[NULL]';
   return from-json($x);
}

method BUILD {
    $.db = $db if $db;
    return if $.db;
    my $database =  %*ENV<PGDATABASE> or die "Please set PGDATABASE";
    debug "connecting to database $database";
    $db = DBIish.connect("Pg", database => $database, :!RaiseError);
    $.db = $db;
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
        CATCH { default { False; } }
        $.sth.execute(|@bind);
     } or do {
        $.errors = $.sth.errstr;
        error "Error: $.errors";
        return False;
    };
    @.results = $.sth.allrows();
    trace "done getting results";
    return True;
}

#| The most recent result if there is only one value.
method result {
    return @.results unless @.results==1;
    return @.results[0] unless @.results[0]==1;
    return @.results[0][0];
}

method column {
    return @.results.map({ .[0] })
}

method json {
    return unless $.result;
    return decode-json($.result);

}

method jsonv {
    for @.results -> $r {
        $r[1] = decode-json($r[1]);
    }
    self.results;
}

method upsertjson($k,$json,$table='kv') {
    self.query: "insert into kv (k,v) values (?,?) on conflict (k) do update set v=?",
        $k, to-json($json), to-json($json) or return False;
    return True;
}

