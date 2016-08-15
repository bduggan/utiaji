use JSON::Fast;
use DBIish;

use Utiaji::Handler;
use Utiaji::Router;
use Utiaji::Log;
use Utiaji::Template;

#| Utiaji::App is the base class for apps.
unit class Utiaji::App does Utiaji::Handler;

has $.root is rw = $?FILE.IO.parent.parent.dirname;
has $.template-path = 'templates';
has $.template-suffix = 'html.ep6';
has $.router handles <get post put> = Utiaji::Router.new;

method new {
    my $self = callsame(|%_);
    $self.setup();
    $self;
}

method setup {}

my %mime-types = text => 'text/plain',
                 json => 'application/json',
                 html => 'text/html';

method render_not_found($res) {
    self.render: $res, :body("not found"), :type<text>, :404status
}

multi method render($res, Pair $p) {
    samewith $res, template => $p.key, template_params => $p.value
}

multi method render($res, :$text!, :$status=200) {
    samewith $res, :type<text>, :body($text), :$status
}

multi method render($res, :$json!, :$status=200) {
    my $out = to-json($json);
    samewith $res, :type<json>, :body($out), :$status
}

multi method render($res!, :$template!, :%template_params is copy, :$status=200) {
    my $t = self.load-template($template) or return self.render_not_found($res);
    %template_params<app> = self;
    debug "sending session : " ~ $res.session.gist;
    %template_params<session> = $res.session;
    samewith $res, :type<html>, :body( $t.render(|%template_params) ), :$status
}

multi method render($res, :$type='text', :$body='', :$status!) {
    debug "rendering $type";
    $res.headers<content-type> = %mime-types{$type};
    $res.body = ~$body;
    $res.status = $status;
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


