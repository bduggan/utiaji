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




class Utiaji::Request {
    has Str $.raw;
    has $.matched;

    method parse-request($raw) {
        trace "parsing request";
        my $match = Utiaji::Request::Grammar.parse($raw);
        unless $match {
            trace "did not parse request { $.raw.perl }";
            return False;
        }
        say $match.say;
        # $.matched = $match.hash.clone;
        return True;
    }
}
