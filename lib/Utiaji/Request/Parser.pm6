unit module Utiaji::Request::Parser;
use Utiaji::Log;

grammar header-parser {
     rule TOP {
        <verb> <path> "HTTP/1.1" \n
        <headers>
     }
     token ws { \h* }
     token verb {
         GET | POST | PUT
     }
     token path {
         '/' <segment>* %% '/'
     }
     token segment {
         [ <alpha> | <digit> | '+' | '-' | '.' ]*
     }
     rule headers {
        [ <header> \n ]*
     }
     rule header {
        <field-name> ':' <field-value>
     }
     token field-name {
         <-[:]>+
     }
     token field-value {
         <-[\n\r]>+
     }
}

class header-actions {
    method TOP($/) {
        $/.make: Utiaji::Request.new:
            path => $<path>.made,
            method => $<verb>.made,
            headers => $<headers>.made,
    }
    method headers($/) {
        $/.make: Utiaji::Headers.new:
        fields => [ map {.made }, $<header> ]
    }
    method header($/) {
        $/.make: $<field-name>.made => $<field-value>.made
    }
    method path($/) { $/.make: ~$/; }
    method verb($/) { $/.make: ~$/; }
    method field-name($/) { $/.make: ~$/ }
    method field-value($/) { $/.make: ~$/ }
}

sub parse-json-body {
    ...
}

sub parse-headers($raw) is export {
    my $actions = header-actions.new;
    my $match = header-parser.parse($raw, :$actions);
    unless $match {
        error "did not parse request { $raw.perl }";
        return;
    }
    my $request = $match.made;
    $request.headers.normalize;
    return $request;
}

