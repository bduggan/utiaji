
unit class Utiaji::RequestLine;
use Utiaji::Log;

has $.raw;
has $.path is rw;
has $.verb is rw;
has $.query is rw;
has %.query-params is rw;

my grammar parser {
     rule TOP {
        <verb> <path>['?'<query>]? "HTTP/1.1"
     }
     token ws { \h* }
     token verb {
         GET | POST | PUT | HEAD | DELETE
     }
     token path {
         '/' <segment>* %% '/'
     }
     token segment {
         [ <alpha> | <digit> | '+' | '-' | '.' | ':' ]*
     }
     token query {
         [ <alpha> | <digit> | '=' | ':' | '/' | '&' | '+' | '-' | '.' | ';']*
     }
}

my class actions {
    has Utiaji::RequestLine $.made;

    method TOP($/) {
        $!made.path = $<path>.made;
        $!made.verb = $<verb>.made;
        $!made.query = $<query>.made;
    }
    method path($/) { $/.make: ~$/; }
    method verb($/) { $/.make: ~$/; }
    method query($/) { $/.make: ~$/; }
}

method parse {
    my $actions = actions.new(made => self);
    parser.parse($!raw, :$actions) or return;
    if self.query {
        my @paired = self.query.split('&').map({.split('=')});
        my %h;
        for @paired -> $p {
            if %h{$p[0]}:exists {
                %h{$p[0]} = [ %h{$p[0]} ] unless %h{$p[0]}.isa("Array");
                push %h{$p[0]}, $p[1];
                next;
            }
            %h{$p[0]} = $p[1];
        }
        %!query-params = %h;
    }
    self
}

