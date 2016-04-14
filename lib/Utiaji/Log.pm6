class Utiaji::Log {

    has            $.level is rw = %*ENV<UTIAJI_LOG_LEVEL> || 'info';
    has IO::Handle $!fh; #= filehandle
    has            $.path   is rw;

    method fh {
        if $!path && not $!fh {
            $!fh = open($!path, :w);
        }
        return $!fh // $*OUT;
    }

    sub trace($msg) is export { logger.trace($msg) }
    sub debug($msg) is export { logger.debug($msg) }
    sub error($msg) is export { logger.error($msg) }
    sub info($msg)  is export { logger.info($msg) }

    method trace($msg) {
        return unless $.level eq 'trace';
        my $back  = Backtrace.new;
        my $frame = $back.first: -> $f { !$f.is-setting and $f.file ne $?FILE };
        my $file = $frame.file;
        my $line = $frame.line;
        my $out = $msg ~ " [ +$line {$file} ]";
        $out ~= " in {$frame.subname}" if $frame.subname;
        $.fh.say("# {now.DateTime} $out");
    }

    method debug($msg) {
        return unless $.level ~~ / debug | trace /;
        $.fh.say("# {now.DateTime} debug: $msg");
    }

    method error($msg) {
        $.fh.say( "# {now.DateTime} error: $msg");
    }

    method info($msg) {
        $.fh.say("# {now.DateTime} info: $msg");
    }
}

sub logger is export {
    state $logger //= Utiaji::Log.new;
    $logger;
}

=begin pod

=head1 SYNOPSIS

    use Utiaji::Log;

    logger.level = 'debug';
    debug 'debug message';
    error 'error mesaage';
    info 'some info';

=end pod

