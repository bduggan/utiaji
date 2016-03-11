unit class Utiaji::Log;

has $.level is rw = %*ENV<UTIAJI_LOG_LEVEL> || 'info';
# see http://doc.perl6.org/language/classtut

method new {!!!}

my Utiaji::Log $logger;

sub logger() is export {
    Utiaji::Log.logger
}

submethod logger() {
    $logger = Utiaji::Log.bless unless $logger;
    $logger;
}

sub trace($msg) is export { $logger.trace($msg) }
sub debug($msg) is export { $logger.debug($msg) }
sub error($msg) is export { $logger.error($msg) }
sub info($msg)  is export { $logger.info($msg) }

method trace($msg) {
    return unless $.level eq 'trace';
    my $back  = Backtrace.new;
    my $frame = $back.first: -> $f { !$f.is-setting and $f.file ne $?FILE };
    my $file = $frame.file;
    my $line = $frame.line;
    my $out = $msg ~ " [ +$line {$file} ]";
    $out ~= " in {$frame.subname}" if $frame.subname;
    say "# $out" # {$line}";
}

method debug($msg) {
    return unless $.level ~~ / debug | trace /;
    say "# debug: $msg";
}

method error($msg) {
    say "# error: $msg";
}

method info($msg) {
    say "# info: $msg";
}
