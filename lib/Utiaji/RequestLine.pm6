
unit class Utiaji::RequestLine;
use Utiaji::Log;

has $.raw;
has $.path is rw;
has $.verb is rw;

grammar parser {
     rule TOP {
        <verb> <path> "HTTP/1.1"
     }
     token ws { \h* }
     token verb {
         GET | POST | PUT | HEAD | DELETE
     }
     token path {
         '/' <segment>* %% '/'
     }
     token segment {
         [ <alpha> | <digit> | '+' | '-' | '.' ]*
     }
}

class actions {
    has Utiaji::RequestLine $.made;

    method TOP($/) {
        $!made.path = $<path>.made;
        $!made.verb = $<verb>.made;
    }
    method path($/) { $/.make: ~$/; }
    method verb($/) { $/.make: ~$/; }
}


method parse {
    my $actions = actions.new(made => self);
    my $match = parser.parse($!raw, :$actions);
    unless $match {
        error "did not parse request line { $!raw.perl }";
        return;
    }
    self
}



