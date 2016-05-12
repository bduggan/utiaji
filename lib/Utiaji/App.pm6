use JSON::Fast;
use DBIish;

use Utiaji::Router;
use Utiaji::Log;
use Utiaji::Template;

#| Utiaji::App is the base class for apps.
unit class Utiaji::App;

has $.root is rw = $?FILE.IO.parent.parent.dirname;
has $.template-path = 'templates';
has $.template-suffix = 'html.ep6';
has $.router handles <get post put> = Utiaji::Router.new;

multi method render($res, :$text!, :$status=200) {
    trace "rendering text";
    $res.headers<content-type> = 'text/plain';
    $res.body = $text;
    $res.status = $status;
}

multi method render($res, :$json!, :$status=200) {
    trace "rendering json";
    $res.headers<content-type> = 'application/json';
    $res.status = $status;
    $res.body = to-json($json);
}

method load-template($template) {
    my $path = "$.root/$.template-path/$template\.$.template-suffix";
    $path.IO.e or do {
        debug "$path not found";
        return;
    }
    Utiaji::Template.new(cache-key => $path).parse($path.IO.slurp)
}

multi method render($res, :$template!, :%template_params is copy) {
    trace "rendering template $template";
    my $t = self.load-template($template) or return self.render_not_found($res);
    $res.headers<content-type> = "text/html";
    %template_params<app> = self;
    $res.body = $t.render(|%template_params);
    $res.status = 200;
}

multi method render($res, :$status!) {
    # NB, must be declared below the ones above.
    trace "rendering status $status";
    $res.headers<content-type> = 'text/plain';
    $res.status = $status;
}

multi method render($res, Pair $p) {
    my $template = $p.key;
    my $params = $p.value;
    self.render: $res, template => $template, template_params => $params;
}

method render_not_found($res) {
    $res.status = 404;
    $res.body = 'not found';
    $res.headers<content-type> = 'text/plain';
}

method redirect_to($res, $path) {
   $res.headers{"Location"} = $path;
   $res.status = 302;
}

my $app;
method new {
    my $self = callsame(|%_);
    $app = $self;
    $self.setup();
    $self;
}

sub app is export { $app }

method setup {
    # override in subclasses
}
