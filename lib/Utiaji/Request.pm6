use Utiaji::Log;

grammar Utiaji::Request::Grammar {
     rule TOP {
        <verb> '/' 'HTTP/1.1' \n
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

class Utiaji::Request::Grammar::Actions {
    method TOP($/) {
        $/.make: 42;
    }
}



class Utiaji::Request {
    has Str $.raw is rw;
    has $.matched is rw;

    method parse-request($raw) {
        $.raw = $raw;
        my $match = Utiaji::Request::Grammar.parse($raw);
        unless $match {
            trace "did not parse request { $.raw.perl }";
            return False;
        }
        $.matched = $match.clone;
        return True;
    }
}
