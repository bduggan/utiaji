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
    for %in<accepts>.flat -> $a {
        ok match-pattern($pattern, $a), "%in<pattern> matches $a";
    }
    for %in<rejects>.flat -> $r {
        ok !match-pattern($pattern, $r), "%in<pattern> does not match $r";
    }
}

done-testing;
