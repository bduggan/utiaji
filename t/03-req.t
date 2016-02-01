#!/usr/bin/env perl6

use v6;
use lib 'lib';
use HTTP::Tinyish;

use Utiaji;
use Test;

# TODO find a port
my $port = 9999;
my $base = "http://localhost:$port";
use JSON::Fast;

my $u = Utiaji.new;
$u.start($port);
sleep 2;

my $ua = HTTP::Tinyish.new;
my %res = $ua.get("$base");

is %res<content>, 'Welcome to Utiaji.', 'got content';
is %res<status>, 200, 'status 200';
is %res<headers><content-type>, 'text/plain', 'content type';

%res = $ua.get("$base/no/such/place");
is %res<status>, 404, "404 not found";

# Send invalid JSON
%res = $ua.post("$base/set/foo",
    headers => "Content-type" => 'application/json',
    content => 'not v{ a ) } (lid JSON ');
is %res<status>, 400, "error for invalid json";
is %res<headers><content-type>, 'application/json', 'content type';

# Send good JSON
%res = $ua.post("$base/set/foo",
    headers => "Content-type" => 'application/json',
    content => to-json( { abc => 123 } ) );
is %res<status>, 200, "post ok";
is %res<headers><content-type>, 'application/json', 'content type';
my $json = from-json(%res<content>);
is-deeply $json, { "status" => "ok" }, "got response";

# Send duplicate key
%res = $ua.post("$base/set/foo",
    headers => "Content-type" => 'application/json',
    content => to-json( { abc => 456 } ) );
is %res<status>, 400, "duplicate key";
is %res<headers><content-type>, 'application/json', 'content type';

# Delete it
%res = $ua.post("$base/del/foo",
    headers => "Content-type" => 'application/json');
is %res<status>, 200, "delete ok";
is %res<headers><content-type>, 'application/json', 'content type';



