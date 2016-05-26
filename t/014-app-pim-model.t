use lib 'lib';
use Test;
use Utiaji::Model::Pim;
use Utiaji::DB;
use Utiaji::Test;

my $db = Utiaji::DB.new;
my $pim = Utiaji::Model::Pim.new;

$db.query('delete from kk');
$db.query('delete from kv');

ok so $pim.cal, "pim has a calendar";
ok so $pim.wiki, "pim has a wiki";

ok $pim.save(day => Day.new(date => '2016-01-02', text => "jan 2 day")), 'saved';
$pim.cal.load(:from<2016-01-02>,:to<2016-01-02>);
is $pim.cal.days.elems, 1, '1 day';
ok $pim.cal.align, 'align';

is $pim.cal.from.day-of-week, 7, 'align to sunday';
is $pim.cal.to.day-of-week, 6, 'last is saturday';

$pim.cal.load(year => 2016, month => 1);

my %init = $pim.cal.initial_state;
my %expect =
  data => { "2016-01-02" => "jan 2 day" },
  first => [2016, 0, 1],
  month_index => 0,
  year => 2016;
is-deeply %init, %expect, 'initial data';

ok %init<first>:exists, 'first day';
ok %init<month_index>:exists, 'month index';
ok %init<data>:exists, 'data';

{
my $day = Day.new( date => "2011-01-01", text => 'something @big');
ok $day.date.isa('Date'), 'coercion';
ok $pim.save(:$day), 'saved';

my $page = $pim.page("big");
is $page.name, 'big', 'saved and loaded page';
is $page.refs-in.elems, 1, '1 ref to this page';
is $page.refs-in[0], 'date:2011-01-01', "the right day";
}

{
my $day = Day.new(date => "2011-01-01", text => 'something @small');
ok $pim.save(:$day), 'saved day';
my $page = $pim.page("big");
is $page.refs-in.elems, 0, "no dates link to big anymore";
}

done-testing;

