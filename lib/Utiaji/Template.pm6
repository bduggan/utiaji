unit class Utiaji::Template;
use Utiaji::Log;

has $.raw;
has $.parsed;

grammar parser {
    rule TOP {
      [   <line=statement>
        | <line=text>
     ] *
    }

    token statement {
        '%' [ <expression> | <comment> | <code> ] \n
    }

    token expression { '=' \V* }
    token comment { '#' \V* }
    token code { \V* }

    regex text {
        <!after '%'>
        [
            <piece=verbatim>
        |
         [ <inline-start>
            [ <piece=inline-code> | <piece=inline-expression> ]
          <inline-end>
         ]
        ]*
        \n
    }

    regex verbatim {
        [ <-[<\v]> | '<' <-[%\v]> ]+
    }

    token inline-code { <-[\v%]>+ }
    token inline-expression { '=' <-[\v%]>+ }

    token inline-start { '<%' }
    token inline-end   { '%>' }

}

class actions {
    method TOP($/) {
        say $<line>;
        $/.make( grep { .defined }, map { .made }, $<line> );
    }

    method text($/) {
        say " text '$/'";
        #my $str = chomp ~$/;
        # $/.make: "@out.push: q[$str];\n";
        $/.make: [ ( map { .made }, $<piece> ), '@out.push: "\n";' ];
        say "text made '{$/.made}'";
    }

    method inline-code($/) {
        say "------->inline code: $/";
        my $str = chomp ~$/;
        $/.make: $str ~ "\n";
    }

    method inline-expression($/) {
        say "------->inline expression $/";
        my $str = chomp ~$/;
        $str.=subst( /^ '=' /,'');
        $/.make: "@out.push: $str;\n";
    }

    method verbatim($/) {
        say "-------->verbatim '$/'";
        $/.make: "@out.push: q[$/];\n";
    }

   method statement($/) {
        my $str = ~$/;
        $str .= subst(/^ '%' /,'');
        $/.make: $<expression>.made || $<code>.made;
    }

    method expression($/) {
        my $str = chomp ~$/;
        $str .= subst(/^ '='/,'');
        $/.make: "@out.push: $str\n;"
    }

    method comment($/) {
        $/.make: Nil
    }

    method code($/) {
        $/.make: ~$/;
    }

}

multi method parse($!raw) {
    self.parse;
}

multi method parse {
    my $act = actions.new;
    my $raw = chomp($.raw) ~ "\n";
    my $p = parser.parse($raw, actions => $act) or die "did not parse $raw";
    use MONKEY-SEE-NO-EVAL;
    my $head = ' sub { my @out = (); ';
    my $tail = ' return @out; } ';

    my @lines = $p.made;
    my $code = join "\n", $head, @lines, $tail;
    trace "---code--";
    trace $code;
    trace "---------";
    $!parsed = EVAL $code;
    self;
}

method render {
   self.parse unless $.parsed;
   my $out = $!parsed().join("");
   $out.=chomp unless $!raw ~~ /\n $/;
   return $out;
}

