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

# Utiaji::App is a singleton.  Override setup to customize routes.
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

# We handle these types:
my %types = text => 'text/plain',
            json => 'application/json',
            html => 'application/html';

multi method render($res, :$text!, :$status=200) {
    self.render($res, :type<text>, :body($text), :$status);
}

multi method render($res, :$json!, :$status=200) {
    self.render($res, :type<json>, :body(to-json($json)), :$status);
}

multi method render($res, :$template!, :%template_params is copy, :$status=200) {
    trace "rendering template $template";
    my $t = self.load-template($template) or return self.render_not_found($res);
    %template_params<app> = self;
    self.render($res, :type<html>, :body( $t.render(|%template_params) ), :$status);
}

multi method render($res, :$type='text', :$body='', :$status!) {
    trace "rendering $type";
    $res.headers<content-type> = %types{$type};
    $res.body = $body;
    $res.status = $status;
}

method render_not_found($res) {
    self.render: $res, :body<not found>, :type<plain>, :404status;
}

multi method render($res, Pair $p) {
    my $template = $p.key;
    my $params = $p.value;
    self.render: $res, template => $template, template_params => $params;
}

method load-template($template) {
    my $path = "$.root/$.template-path/$template\.$.template-suffix";
    $path.IO.e or do {
        debug "$path not found";
        return;
    }
    Utiaji::Template.new(cache-key => $path).parse($path.IO.slurp)
}

method redirect_to($res, $path) {
   $res.headers{"Location"} = $path;
   $res.status = 302;
}


