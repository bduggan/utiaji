use v6;
use lib 'lib';
use Test;
use Utiaji::Template;

my $t = Utiaji::Template.new;

ok $t.parse("Four score"), 'parsed';
is $t.render, "Four score", "simple string";

ok $t.parse("nother"), 'parsed another';
is $t.render, "nother", 'rendered another';

ok $t.parse(q:to/DONE/), 'parsed expression';
%= 1 + 1
DONE
is $t.render, "2\n", 'rendered expression';

ok $t.parse(q:to/DONE/), 'parsed comments';
something
%# is not
here
DONE
is $t.render, "something\nhere\n", "rendered comments";

ok $t.parse(q:to/DONE/), 'parse code';
% for 1..5 {
ditto
% }
DONE
is $t.render, "ditto\n" x 5, "rendered code";

ok $t.parse(q:to/DONE/), 'code + expressions';
% for 1..5 -> $x {
%= $x
% }
DONE
is $t.render, [1..5].join("\n") ~ "\n", 'rendered';

ok $t.parse("1 + 2 is <%= 1 + 2 %>."), "inline expr parse";
is $t.render, "1 + 2 is 3.", 'inline expr render';

ok $t.parse("percent inside <%= '%' %>."), 'percent inside';
is $t.render, 'percent inside %.', 'percent literal';

# not doing: "<%= '%>' %>"

ok $t.parse("<%= 2 + 2 %> > <%= 9 - 6 %>"), 'parse two inlines';
is $t.render, "4 > 3", 'render two inlines';

ok $t.parse('<% for 1..6 -> $x { %><%= $x %><% } %>'), 'parse inline code';
is $t.render, '123456', 'render inline code';

ok $t.parse(q:to/DONE/), 'parse with signature line';
%| :$name
hello, <%= $name %>
DONE
is $t.render(name => 'joe'), "hello, joe\n", 'rendered with params';

ok $t.parse(q:to/DONE/), 'parse with signature line';
%| :$content
hello, <%= $content %>
DONE
is $t.render(content => 'caffeine'), "hello, caffeine\n", 'rendered with params';

ok $t.parse(q:to/DONE/), 'parse with signature line with types';
%| :$content, Int :$number where * > 0
hello, <%= $content %> + <%= $number %>
DONE
is $t.render(content => 'coffee', number => 12), "hello, coffee + 12\n", 'rendered with params';

ok $t.parse("%= '<&>'"), 'parsed';
is $t.render, '&lt;&amp;&gt;', 'escaped';

ok $t.parse("<%= '<&>' %>"), 'parsed';
is $t.render, '&lt;&amp;&gt;', 'escaped';

ok $t.parse("%== '<&>'"), 'parsed';
is $t.render, '<&>', 'not escaped';

ok $t.parse("<%== '<&>' %>"), 'parsed';
is $t.render, '<&>', 'not escaped';

ok $t.parse("<%= 12 %>"), 'parsed';
is $t.render, '12', 'escaped';

done-testing;

