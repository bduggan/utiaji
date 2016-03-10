use v6;

# NB: use lib must go first
use lib 'lib';

use DBIish;
use Test;

my $db = %*ENV<PGDATABASE>;
unless $db {
    plan 1;
    skip-rest "Set PGDATABASE for database testing";
    exit;
}

diag "PGDATABASE=$db";

ok $db, 'PGDATABASE is set';

my $dbh = DBIish.connect("Pg", :database($db));

ok $dbh, "Made a database handle.";

my $sth = $dbh.prepare("select 42");

ok $sth, "Made a statement handle.";

ok $sth.execute, "Executed a statement.";

my $results = $sth.fetchall_arrayref();

ok $results, "Got results.";

is $results, 42, "Got the right results.";

ok $sth = $dbh.prepare(q{select '{"a":"42"}'::json->'a'}), 'JSON datatype';

ok $sth.execute, "JSON execute";

$results = $sth.fetchall_arrayref();

is $results, q["42"], "Got 42 for JSON element";

ok $dbh.disconnect, "Disconnect.";

done-testing;

