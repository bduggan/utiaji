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
my $cal = $pim.cal.align;

is $cal.from.day-of-week, 7, 'align to sunday';
is $cal.to.day-of-week, 6, 'last is saturday';
ok $cal.load, 'load';

my %init = $cal.initial_state;
diag %init.perl;
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

