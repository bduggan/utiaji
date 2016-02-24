#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Utiaji::Server;
use Utiaji::Test2;

my $s = Utiaji::Server.new;
my $t = Utiaji::Test2.new;

$s.start;

$t.get_ok('/').status_is(200);

done-testing;

