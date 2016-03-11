use v6;
use lib 'lib';
use Test;
use Utiaji::Pattern;

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
    my $pattern = Utiaji::Pattern.new(pattern => %in<pattern>);
    my $i = 0;
    for %in<accepts>.flat -> $a {
       ok $pattern.match($a), "$pattern matches $a";
       my %want = %in<captures>[$i++].hash;
       is-deeply %want, $pattern.capture-hash, "Right captures";
    }
    for %in<rejects>.flat -> $r {
       ok !$pattern.match($r), "$pattern does not match $r";
    }
}

done-testing;
