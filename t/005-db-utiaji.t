use v6;
use lib 'lib';
use Test;
use Utiaji::DB;

unless %*ENV<PGDATABASE> {
    plan 1;
    skip-rest "Set PGDATABASE for database testing";
    exit;
}

my $db = Utiaji::DB.new;

ok $db, 'made an Utiaji::DB';

ok $db.query("select 101"), "Query ok";

is $db.result, 101, "Single value";

ok $db.query("select version()"), "Selected version";

diag $db.results;

ok $db.query("select typname from pg_catalog.pg_type where typname = 'jsonb'"), "find jsonb";

is $db.result, 'jsonb', 'have jsonb type';

ok $db.query("select 102"), "Query ok";

is $db.result, 102, "Single value";

ok $db.query(q[select '{"x":"999"}'::json]), "json query";

is-deeply $db.json, { x => '999' }, 'json result';

done-testing;

