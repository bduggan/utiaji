unit module Utiaji::Log;

my $level = %*ENV<UTIAJI_LOG_LEVEL> || 'debug';

sub trace($msg is copy) is export {
    return unless $level ~~ /^(trace|debug)$/;
    my $back  = Backtrace.new;
    my $frame = $back.first: -> $f { !$f.is-setting and $f.file ne $?FILE };
    my $file = $frame.file;
    $file ~~ s/^$*CWD/./;
    $msg ~= " in {$frame.subname}" if $frame.subname;
    say "# $msg at {$file} {$frame.line}";
}

sub debug($msg) is export {
    return unless $level eq 'debug';
    my $back  = Backtrace.new;
    my $frame = $back.first: -> $f { !$f.is-setting and $f.file ne $?FILE };
    my $file = $frame.file;
    $file ~~ s/^$*CWD/./;
    $msg ~= " in {$frame.subname}" if $frame.subname;
    say "# $msg at {$file} {$frame.line}";
}
