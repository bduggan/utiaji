unit module Utiaji::Log;
my $level = 'debug';

sub trace($msg) is export {
    say "$msg" if $level eq 'trace';
}
