unit class Utiaji::Pattern;
use Utiaji::Log;

has Str $.pattern;
has Str $.rex is rw;       # Compiled pattern ( used within a regex )
has Match $.captures is rw;

# Parse a route pattern.
my grammar parser {
    token TOP          { '/' <part> *%% '/' }
    token part         { [ <placeholder> '.' <literal> ] || <literal> || <placeholder> }
    token literal      { [ <[0..9]> | <[a..z]> | '-' | '_' | '.' ]+ }

    token placeholder  {
              <placeholder_word>
            | <placeholder_ascii_lc>
            | <placeholder_date>
            | <placeholder_class>
        }
    token placeholder_word     { ':' <var> }
    token placeholder_ascii_lc { '∙' <var> } # bullet : Sb
    token placeholder_date     { 'Δ' <var> } #  delta : D*
    token placeholder_class    { '∷' <var> } #  proportion : ::

    token var { <[a..z]>+ }
}

use MONKEY-SEE-NO-EVAL;
# NB: It is possible to avoid the above and just use =placeholder*, but
# then there are extra named captures.
my class actions {
    method TOP($/)     {
        $/.make: q[ '/' ] ~ join q[ '/' ], map { .made }, $<part>;
    }
    method part($/)    {
        if $<literal>.made && $<placeholder>.made {
            return $/.make: $<placeholder>.made ~ " '.' " ~ $<literal>.made
        }
        return $/.make: $<literal>.made || $<placeholder>.made;
    }
    method placeholder($/){
        $/.make: $<placeholder_word>.made
              // $<placeholder_ascii_lc>.made
              // $<placeholder_date>.made
              // $<placeholder_class>.made
          }

    method placeholder_word($/)     { $/.make: "<" ~ $<var>.made ~ '=&placeholder_word>'; }
    method placeholder_ascii_lc($/) { $/.make: "<" ~ $<var>.made ~ '=&placeholder_ascii_lc>'; }
    method placeholder_date($/)     { $/.make: "<" ~ $<var>.made ~ '=&placeholder_date>'; }
    method placeholder_class($/)     { $/.make: "<" ~ $<var>.made ~ '=&placeholder_class>'; }

    method var($/)     {
        $/.make: ~$/;
    }
    method literal($/) {
        $/.make: "'$/'";
    }
}

my regex placeholder_word     { [ \w | '-' ]+ }
my regex placeholder_ascii_lc { [ <[a..z]> | <[0..9]> | '_' | '-' ]+ }
my regex placeholder_date     { <[0..9]>**4 '-' <[0..9]>**2 '-' <[0..9]>**2 }
my regex placeholder_class    { [ \w | ':' ]+ }

method !compile {
    $.rex //= do {
        trace "compiling $.pattern";
        my $parser = parser.parse( $.pattern, actions => actions.new) or
            die "could not parse $.pattern";
        $parser.made;
    };
}

method match(Str $path) {
    self!compile;
    trace "comparing $path to $.rex";
    my $result = $path ~~ rx{ ^ <captured={$.rex}> $ };
    $.captures = $<captured>.clone;
    return $result;
}

method caught {
    my %h = $.captures.hash;
    my %i = map { $_ => ~%h{$_} }, keys %h;
    %i;
}

method Str {
    $.pattern;
}
