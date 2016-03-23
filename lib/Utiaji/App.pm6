use JSON::Fast;
use DBIish;

use Utiaji::Router;
use Utiaji::Log;
use Utiaji::Template;

unit class Utiaji::App;

has Utiaji::Router $.router = Utiaji::Router.new;
has $.root is rw = $?FILE.IO.dirname ~ "/../..";
has $.template_path = 'templates';
has $.template_suffix = 'html.p6';
has $.template = Utiaji::Template.new;

method handler {
    return sub ($req, $res) {
        my ($route,$matches) = self.router.lookup(
            verb => $req.method,
            path => $req.uri,
        );
        trace "{$req.method} {$req.uri} ";
        if $route {
            my $cb = $route.code();
            my $content_type = $req.headers<Content-type>;
            if ($content_type and $content_type eq 'application/json') {
                trace "Got JSON";
                my $json;
                # TODO simplify, also log parse errors
                try { $json = from-json($req.data.decode('UTF-8').chop); };
                if ($matches.hash.elems) {
                    return $cb($req,$res,$matches.hash,$json);
                }
                return $cb($req,$res,$json);
            }
            if ($matches.hash.elems) {
                return $cb($req,$res,$matches.hash);
            }
            return $cb($req,$res);
        }
        $res.status = 404;
        $res.headers<Connection> = 'Close';
        $res.write("Not found: { $req.method } { $req.uri }\nAvailable routes :\n");
        for self.router.routes.flat -> $r {
            $res.write($r.gist);
            $res.write("\n");
        }
        $res.close("Sorry, not found\n");
    }
}

multi method render($res, :$text!, :$status=200) {
    trace "rendering text";
    $res.headers.content-type = 'text/plain';
    $res.body = $text;
    $res.status = $status;
}

multi method render($res, :$json!, :$status=200) {
    trace "rendering json";
    $res.headers.content-type = 'application/json';
    $res.status = $status;
    $res.body = to-json($json);
}

multi method render($res, :$static!, :$status=200) {
    trace "rendering static $static";
    $res.headers.content-type = 'text/html';
    my $path = $.root ~ "/static/$static";
    $path.IO ~~ :e or do { info "$path not found"; return self.render_not_found($res); };
    $res.status = $status;
    $res.body = $path.IO.slurp;
}

multi method render($res, :$template!, :%template_params) {
    trace "rendering template $template";
    my $path = "$.root/$.template_path/$template\.$.template_suffix";
    $path.IO.e or do {
        debug "$path not found";
        return self.render_not_found($res);
    };
    $res.headers.content-type = "text/html";
    $res.body = $.template
        .parse($path.IO.slurp)
        .render(|%template_params);
    $res.status = 200;
}

multi method render($res, :$status!) {
    # NB, must be declared below the ones above.
    trace "rendering status $status";
    $res.headers.content-type = 'text/plain';
    $res.status = $status;
}

method render_not_found($res) {
    $res.status = 404;
    $res.body = 'not found';
    $res.headers.content-type = 'text/plain';
}

