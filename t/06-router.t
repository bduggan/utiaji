use v6;
use Test;
use lib 'lib';

use Utiaji::Router;

my @tests = (
   { pattern  => '/',
     accepts  => [ '/' ],
     captures => [ {}  ],
     rejects  => [ '', 'foo', '*', '.' ],
   },
   { pattern  =>  '/foo',
     accepts  => [ '/foo' ],
     captures => [ {}     ],
     rejects  => [ '/fo', '/fooo', 'fo', '/foo/bar' ],
   },
   { pattern  => '/name/:first',
     accepts  => [ '/name/joe',        '/name/Étienne',       '/name/名' ],
     captures => [ {first => 'joe'},  { first => 'Étienne' }, { first => '名' } ],
     rejects  => [ '/name/', '/name', '/name/x/y', '/nom', '/name/%' ],
   },
   { pattern  => '/word/:w',
     accepts  => [ '/word/12-23-45', '/word/a_b-cdEFG' ],
     captures => [ { w => '12-23-45'}, { w => 'a_b-cdEFG' } ],
     rejects  => [ '/word/a b' ],
   },
   { pattern  => '/wiki/_page',
     accepts  => [ '/wiki/abc',       '/wiki/123',       '/wiki/a_b-d' ],
     captures => [ { page => 'abc' }, { page => "123" }, { page => 'a_b-d' } ],
     rejects  => [ '/wiki/a.d', '/wiki/ABC' ],
   }
);

for @tests -> %in {
    my $pattern = %in<pattern>;
    my $matcher = Utiaji::Matcher.new(pattern => $pattern);
    my $i = 0;
    for %in<accepts>.flat -> $a {
       ok $matcher.match($a), "$pattern matches $a";
       is-deeply $matcher.captures, %in<captures>[$i++].hash, "got captures for $pattern";
    }
    for %in<rejects>.flat -> $r {
       ok !$matcher.match($r), "$pattern does not match $r";
    }
}

done-testing;
