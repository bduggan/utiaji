use v6;
use lib 'lib';
use Test;
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
   },
   { pattern  => '/date/Δwhen',
     accepts  => [ '/date/2012-01-01', '/date/1999-12-20' ],
     captures => [ { when => '2012-01-01' }, { when => '1999-12-20' } ],
     rejects  => [ '/date/2012', '/date/20120202','/date/abcd-ef-gh', '/date/２０１１-１１-１１'],
   }
);

for @tests -> %in {
    my $pattern = %in<pattern>;
    my $matcher = Utiaji::Matcher.new(pattern => $pattern);
    my $i = 0;
    for %in<accepts>.flat -> $a {
       diag "result: " ~ $matcher.match($a); #, "$pattern matches $a";
       diag "rex: " ~ $matcher.rex;
       diag "captures: " ~ $matcher.captures.hash;
       my $hash = $matcher.captures.hash;
       my $want = %in<captures>[$i].hash;
       diag "want $want";
       for %in<captures>[$i++].hash.kv -> $k, $v {
             is $hash{$k}, $v, "found $k in match";
       #     is $matcher.captures.hash.flat<$k>, $v, "Matched $k to $v";
       }
       #is-deeply $matcher.captures.hash.flat, %in<captures>[$i++].hash, "got captures for $pattern";
    }
    for %in<rejects>.flat -> $r {
       ok !$matcher.match($r), "$pattern does not match $r";
    }
}

done-testing;
