#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
use Utiaji;
use Utiaji::Test;

my $t = Utiaji::Test.new;

$t.start_server;
$t.get_ok('/')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is('Welcome to Utiaji.');

$t.get_ok("/no/such/url")
  .status_is(404);

done-testing;
