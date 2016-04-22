#| Utiaji provides a webserver with documentation about itself.
use Utiaji::App;
use Utiaji::Log;

unit class Utiaji is Utiaji::App;

method setup {
    app.get: '/',
       -> $req,$res {
          my @files = |$?FILE.IO.dirname.IO.child('Utiaji').dir( test => /:i '.pm6' $/);
          my @classes = "Utiaji", | @files».basename.map({ "Utiaji::$_" }).map({.subst('.pm6','')});
          app.render: $res,
             template => 'main',
             template_params => { classes => @classes.sort }
             ;
       };

    app.get: '/doc/∷class',
       sub ( $req, $res, $/ ) {
           my $class = str2class($<class>);
           my $source = str2url($<class>);
           my $code = str2code($<class>);
           return app.render_not_found: $res if $class eqv False;
           my $why = $class.WHY;
           app.render: $res,
           template => 'doc',
           template_params => { class => $class, pod => $why, source => $source, code => $code }
       }
}

sub str2class($str) {
    if $str eq 'Utiaji' { return Utiaji; }
    if $str ~~ /Utiaji '::' (<[a..zA..Z]>+)/ {
        use MONKEY-SEE-NO-EVAL;
        EVAL "use $str;";
        return EVAL $str;
    }
    return False;
}

sub str2url($str) {
    my $file = $str.subst('::','/'):g;
    return 'https://github.com/bduggan/utiaji/blob/master/lib/' ~ $file ~ '.pm6';
}

sub str2code($str) {
    my $file = $str.subst('::','/'):g;
    return "lib/$file.pm6".IO.slurp;
}


=begin pod

=begin head1

this is the pod

=end head1

=end pod


