#!/usr/bin/env perl6

use lib 'lib2';

use Utiaji;

my $port = 8080;

my $app = Utiaji.new;
$app.start($port);

say "Listening on port $port";
while (True) {
    sleep 1000;
}


