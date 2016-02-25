unit module Utiaji::Log;

my $level = %*ENV<UTIAJI_LOG_LEVEL> || 'debug';

sub trace($msg) is export {
    return unless $level eq 'trace';
    my $back  = Backtrace.new;
    my $frame = $back.first: -> $f { !$f.is-setting and $f.file ne $?FILE };
    my $file = $frame.file;
    my $line = $frame.line;
    my $out = $msg ~ " at {$file} $line";
    $out ~= " in {$frame.subname}" if $frame.subname;
    say "# $out" # {$line}";
}

sub debug($msg) is export {
    return unless $level ~~ / debug | trace /;
    say "# debug: $msg";
}

sub info($msg) is export {
    say "# info: $msg";
}
