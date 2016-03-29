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
             template_params => { classes => @classes }
             ;
       };

    app.get: '/doc/:class',
       -> $req, $res, $/ {
           app.render: $res,
           template => 'doc',
           template_params => { class => $<class> }
       }
}
