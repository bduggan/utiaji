#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Utiaji::Server;
use Utiaji::Test;

my $s = Utiaji::Server.new;
my $t = Utiaji::Test.new;

$s.start;

$t.get_ok('/')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is('Welcome to Utiaji.');;

$s.await;

done-testing;

