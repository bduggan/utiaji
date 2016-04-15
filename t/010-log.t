use v6;
use lib 'lib';
use Test;
use Hamna::Log;

sub nonce () { return (".{$*PID}." ~ 1000.rand.Int) }
my $tmpfile = "logfile" ~ nonce();

{
    my $l = Hamna::Log.new(path => $tmpfile);
    $l.info("hi!");
    my $lines = "$tmpfile".IO.lines;
    cmp-ok $lines, '~~', rx{.* 'info: hi!'}, 'wrote info message';
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
like @lines[0], rx{.* 'debug: debug'}, 'debug message';
like @lines[1], rx{.* 'error: error'}, 'error message';
like @lines[2], rx{.* 'info: info'}, 'info message';

done-testing;

END { unlink $tmpfile }
