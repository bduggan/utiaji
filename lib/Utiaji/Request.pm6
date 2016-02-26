use Utiaji::Log;

class Utiaji::Headers {
    has %.fields;
    method host {
        return %.fields<Host>;
    }
}

class Utiaji::Request {
    has Str $.method is rw;
    has Str $.path is rw;
    has Utiaji::Headers $.headers is rw;
}

grammar Utiaji::Request::Grammar {
     rule TOP {
        <verb> <path> 'HTTP/1.1' \n
        <headers>
        \n
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
         <-[\n]>+
     }
}

class Utiaji::Request::Actions {
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

sub parse-request($raw) is export {
    my $actions = Utiaji::Request::Actions.new;
    my $match = Utiaji::Request::Grammar.parse($raw, :$actions);
    unless $match {
        trace "did not parse request { $raw.perl }";
        return;
    }
    return $match.made;
}
