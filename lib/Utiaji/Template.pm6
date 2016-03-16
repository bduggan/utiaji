unit class Utiaji::Template;

has $.raw;
has $.parsed;

grammar parser {
    rule TOP {
      [   <line=statement>
        | <line=expression>
        | <line=text>
        | <line=comment>
     ] *
    }

    token statement {
        '%' \V* \n
    }

    token expression {
        '%=' \V* \n
    }

    regex text {
        <-[%]>
        [
         <verbatim>
        |
         [ <inline-start>
            [ <inline-code> | <inline-expression> ]
          <inline-end>
         ]
        ]*
        \n
    }

    token verbatim {
        [ <-[<\n]> | '<' <-[%\n]> ]
    }

    token inline-code { <-[\v%]>+ }
    token inline-expression { '=' <-[\v%]>+ }

    token inline-start { '<%' }
    token inline-end   { '%>' }

    token comment {
        '#' \V* \n
    }

}

class actions {
    method TOP($/) {
        $/.make( map { .chomp }, grep { .defined }, map { .made }, $<line> );
    }

    method text($/) {
        my $str = chomp ~$/;
        $/.make: "@out.push: q[$str];\n";
    }

    method statement($/) {
        my $str = ~$/;
        $str .= subst(/^ '%' /,'');
        say "adding statement $str";
        $/.make: $str
    }

    method expression($/) {
        my $str = chomp ~$/;
        $str.=subst(/^ '%='/,'');
        $/.make: "@out.push: $str;"
    }

    method comment($/) {
        $/.make: Nil
    }

    method inline-code($/) {
        say "------->inline code: $/";
    }

    method inline-expression($/) {
        say "------->inline expression $/";
    }

}

multi method parse($!raw) {
    self.parse;
}

multi method parse {
    my $act = actions.new;
    my $raw = chomp($.raw) ~ "\n";
    my $p = parser.parse($raw, actions => $act) or die 'no parse';
    use MONKEY-SEE-NO-EVAL;
    my $head = ' sub { my @out = (); ';
    my $tail = ' return @out; } ';

    my @lines = $p.made;
    my $code = join "\n", $head, @lines, $tail;
    $!parsed = EVAL $code;
    self;
}

method render {
   self.parse unless $.parsed;
   my @out = $!parsed();
   return @out.join( "\n");
}

