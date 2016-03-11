use v6;
use lib 'lib';
use Test;
use Utiaji::Log;

sub nonce () { return (".{$*PID}." ~ 1000.rand.Int) }
my $tmpfile = "logfile" ~ nonce();

{
    my $l = Utiaji::Log.new(path => $tmpfile);
    $l.info("hi!");
    my $lines = "$tmpfile".IO.lines;
    is $lines, "# info: hi!", 'wrote log';
    unlink $tmpfile;
}

logger.path = $tmpfile;
is logger.path, $tmpfile, "set path to $tmpfile";
logger.level = 'debug';
logger.trace('trace');
logger.debug('debug');
logger.error('error');
logger.info('info');

my @lines = "$tmpfile".IO.lines;
is @lines, ["# debug: debug", "# error: error", "# info: info"], 'matched lines';

done-testing;

END { unlink $tmpfile }
