use Utiaji::Log;

# Turns patterns for routes into regexes.

grammar Utiaji::Router {
    token TOP          { '/' <part> *%% '/' }
    token part         { <literal> || <placeholder> }
    token literal      { <[a..z]>+ }

    token placeholder  {
              <placeholder_word>
            | <placeholder_ascii_lc>
            | <placeholder_date> }
    token placeholder_word     { ':' <var> }
    token placeholder_ascii_lc { '_' <var> }
    token placeholder_date     { 'Δ' <var> } # delta : D*

    token var { <[a..z]>+ }
}

class Utiaji::RouterActions {
    method TOP($/)     {
        $/.make: q[ '/' ] ~ join q[ '/' ], map { .made }, $<part>;
    }
    method part($/)    {
        $/.make: $<literal>.made // $<placeholder>.made;
    }
    method placeholder($/){
        $/.make: $<placeholder_word>.made
              // $<placeholder_ascii_lc>.made
              // $<placeholder_date>.made}
    method placeholder_word($/)     { $/.make: "<" ~ $<var>.made ~ '=placeholder_word>'; }
    method placeholder_ascii_lc($/) { $/.make: "<" ~ $<var>.made ~ '=placeholder_ascii_lc>'; }
    method placeholder_date($/)     { $/.make: "<" ~ $<var>.made ~ '=placeholder_date>'; }

    method var($/)     {
        $/.make: ~$/;
    }
    method literal($/) {
        $/.make: ~$/;
    }
}

class Utiaji::Matcher {
    has Str $.pattern is rw;
    has $.captures is rw;

    my regex placeholder_word     { [ \w | '-' ]+ }
    my regex placeholder_ascii_lc { [ <[a..z]> | <[0..9]> | '_' | '-' ]+ }
    my regex placeholder_date     { \d+ '-' \d+ '-' \d+ }

    method match(Str $path) is export {
        my $a = Utiaji::RouterActions.new;
        my $p = Utiaji::Router.parse($.pattern, actions => $a) or return;
        my $rex = $p.made;
        my $result = $path ~~ rx{ ^ <captured=$rex> $ };
        self.captures = $/.hash{'captured'}.clone;
        return $result;
    }
}
