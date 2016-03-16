
use v6;
use lib 'lib';
use Test;
use Utiaji::Template;

my $t = Utiaji::Template.new(raw => "Four score");
$t.parse;
is $t.render, "Four score", "simple string";

# my $str = q:heredoc/END/;
# #| :$a, :$b, :$c
# # comments
# hello there
# % for 1..5 -> $a {
# is it me
# %= $a
# % }
# you're looking for
# %= 12 + 12
# inl<<<<ine <%= "expression" %>
# some code here <% for (1..12) { %> hi <% } %>
# END
#

