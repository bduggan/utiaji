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
           return app.render_not_found: $res if $class eqv False;
           my $why = $class.WHY;
           app.render: $res,
           template => 'doc',
           template_params => { class => $class, pod => $why }
       }
}

sub str2class($str) {
    if $str eq 'Utiaji' { return Utiaji; }
    if $str eq 'Utiaji::DB' { use Utiaji::DB; return Utiaji::DB; }
    if $str eq 'Utiaji::App' { use Utiaji::App; return Utiaji::App; }
    if $str eq 'Utiaji::Body' { use Utiaji::Body; return Utiaji::Body; }
    return False;
}

=begin pod

=begin head1

this is the pod

=end head1

=end pod


