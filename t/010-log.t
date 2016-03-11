use v6;
use lib 'lib';
use Test;
use Utiaji::Log;

sub nonce () { return (".{$*PID}." ~ 1000.rand.Int) }

my $tmpfile = "logfile" ~ nonce();

ok logger, 'have logger';
my $fh = open("$tmpfile", :w);
logger.fh = $fh;

logger.level = 'debug';
logger.trace('trace');
logger.debug('debug');
logger.error('error');
logger.info('info');

$fh.flush;

my @lines = "$tmpfile".IO.lines;
is @lines, ["# debug: debug", "# error: error", "# info: info"], 'matched lines';

done-testing;

END { unlink $tmpfile }
