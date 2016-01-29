#!/usr/bin/env perl6

use v6;
use lib 'lib2';
use HTTP::Tinyish;

use Utiaji;
use Test;

my $port = 9999;

my $u = Utiaji.new;
$u.start($port);
sleep 2;

my $ua = HTTP::Tinyish.new;
my %res = $ua.get("http://localhost:9999/bob");

is %res<content>, 'uncle', 'got content';
is %res<status>, 200, 'status 200';


