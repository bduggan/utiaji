use v6;
use Test;
use lib 'lib';

use Utiaji::Router;

my @tests = (
   { pattern => '/',
     accepts => [ '/' ],
     rejects => [ '', 'foo', '*', '.' ],
   },
   { pattern =>  '/foo',
     accepts => [ '/foo' ],
     rejects => [ '/fo', '/fooo', 'fo', '/foo/bar' ],
   },
   { pattern => '/name/:first',
     accepts => [ '/name/joe', '/name/Étienne', '/name/名' ],
     rejects => [ '/name/', '/name', '/name/x/y', '/nom', '/name/%' ],
   },
   { pattern => '/word/:w',
     accepts => [ '/word/12-23-45', '/word/a_b-cdEFG' ],
     rejects => [ '/word/a b' ],
   },
   { pattern => '/wiki/_page',
     accepts => [ '/wiki/abc', '/wiki/123', '/wiki/a_b-d' ],
     rejects => [ '/wiki/a.d', '/wiki/ABC' ],
   }
);

for @tests -> %in {
    my $pattern = %in<pattern>;
    my $matcher = Utiaji::Matcher.new(pattern => $pattern);
    for %in<accepts>.flat -> $a {
       ok $matcher.match($a), "$pattern matches $a";
       diag $matcher.captures.gist;
    }
    for %in<rejects>.flat -> $r {
       ok !$matcher.match($r), "$pattern does not match $r";
    }
}

done-testing;
