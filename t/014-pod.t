use v6;
use lib 'lib';
use Test;

use Utiaji::Log;

my @doc = Utiaji::Log.WHY;
say Utiaji::Log.HOW.perl;

for @doc -> $doc {
  my $code = $doc.WHEREFORE;

  diag $doc.^name;
  diag $code.perl;
  diag $doc;
  say $doc.HOW.perl;
}


