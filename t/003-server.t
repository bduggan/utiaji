#!/usr/bin/env perl6

use v6;
use Test;

use lib 'lib';
BEGIN { %*ENV<UTIAJI_LOG_LEVEL> //= 'info'; }
use Utiaji::Server;
use Utiaji::Test;

my $s = Utiaji::Server.new;
my $t = Utiaji::Test.new;

$s.start;

$t.get_ok('/')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is("Welcome to Utiaji.");

$t.get_ok('/test')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is("This is a test of the emergency broadcast system.");

$t.post_ok("/echo", json => { abc => 123 } )
  .status_is(200)
  .json_is( { abc => 123 } );

$t.get_ok('/placeholder/bob')
  .status_is(200)
  .content_type_is('text/plain')
  .content_is('bob');

done-testing;

