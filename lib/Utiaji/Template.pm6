unit class Utiaji::Template;
use Utiaji::Log;

has $.raw;
has $.parsed;
has $.cache-key;

grammar parser {
    rule TOP {
     [ ^ '%|' [ $<signature>=[ \V+ ] ] \n ]?
     [    <line=statement>
        | <line=text>
     ] *
    }

    token ws { \h* }

    token statement {
        [ '%' | '▶' ] [ <expression> | <comment> | <code> ] \n
    }

    token expression {
        '=' \V* }
    token comment {
        '#' \V* }
    token code {
        \V* }

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
        $<cr> = [\n]
    }

    regex verbatim {
        [ <-[<\v]> | '<' <-[%\v]> ]+
    }

    token inline-code { <-[\v%]>+ }
    token inline-expression { '=' [ <-[\v%]> | '%' <!before '>'> ] + }

    token inline-start { '<%' }
    token inline-end   { '%>' }

}

sub common-args {
    ':$app, '
}

class actions {
    method TOP($/) {
        my $head = ' sub (';
        $head ~= common-args() ~ ($<signature> ?? $<signature> !! '*%args');
        $head ~= ') { ' ~ "\n";
        $head ~=  'my @out = (); ';
        my @lines = grep { .defined }, $<line>».made;
        my $tail = ' return @out; } ';
        $/.make( join "\n", $head, @lines, $tail );
    }

    method text($/) {
        $/.make: [ $<piece>».made, $<cr>, '@out.push: "\n";' ];
    }

    method inline-code($/) {
        $/.make: ~$/;
    }

    method inline-expression($/) {
        if ($/.substr(0,2) eq '==') {
            my $str = $/.subst( /^ '==' /,'');
            $/.make: "@out.push: $str;";
        } else {
            my $str = $/.subst( /^ '=' /,'');
            $/.make: "@out.push: html-escape($str);";
        }
    }

    method verbatim($/) {
        $/.make: "@out.push: q[$/];\n";
    }

   method statement($/) {
        $/.make: $<expression>.made || $<code>.made;
    }

    method expression($/) {
        if ($/.substr(0,2) eq '==') {
            my $str = $/.subst(/^ '=='/,'');
            $/.make: qq|@out.push: $str;\n @out.push: "\n";\n|
        } else {
            my $str = $/.subst(/^ '='/,'');
            $/.make: qq|@out.push: html-escape($str);\n @out.push: "\n";\n|
        }
    }

    method comment($/) {
        $/.make: Nil
    }

    method code($/) {
        $/.make: ~$/;
    }

    method signature($/) {
        my $str = $/.subst(/^ '-'/,'');
        $/.make: $str;
    }

}

multi method parse($!raw) {
    self.parse;
}

my %cache;
multi method parse {
    if $!cache-key and %cache{$!cache-key}:exists {
        $!parsed = %cache{$!cache-key};
        debug "Using cached template $!cache-key";
        return self;
    }
    debug "Compiling template {$!cache-key // 'no cache-key'}";
    my $act = actions.new;
    my $raw = chomp($.raw) ~ "\n";
    my $p = parser.parse($raw, actions => $act) or do {
        error "did not parse $raw";
        return
    };
    use MONKEY-SEE-NO-EVAL;
    my $code = $p.made;
    trace "---code--";
    trace $code;
    trace "---------";
    $!parsed = EVAL $code;
    %cache{$!cache-key} = $!parsed if $!cache-key;
    debug "Done compiling";
    self;
}

method render(*%params) {
   self.parse unless $.parsed;
   return unless $!parsed;
   my @lines = $!parsed(|%params);
   my $out = @lines.join("");
   $out.=chomp unless $!raw ~~ /\n $/;
   return $out;
}

# helpers
sub include($app, $template, *%args) {
    debug "including $template";
    debug "args : { %args.gist } " if %args;
    my $t = $app.load-template($template) or return "";
    %args<app> = $app;
    return $t.render(|%args);
}

sub html-escape {
   my ($str) = @_;
   $str = $str.gist unless $str.defined;
   $str = ~$str;
   $str.subst-mutate('&','&amp;',:g);
   $str.subst-mutate('<','&lt;',:g);
   $str.subst-mutate('>','&gt;',:g);
   return $str;
}

