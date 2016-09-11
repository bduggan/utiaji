use Utiaji::Log;
use Utiaji::Response;
use Utiaji::Template;

role Utiaji::Renderer {
   has $.template-path = 'templates';
   has $.template-suffix = 'html.ep6';

   my %mime-types = text => 'text/plain',
                    json => 'application/json',
                    html => 'text/html';

    method render_not_found() {
        self.render: :body("not found"), :type<text>, :404status
    }

    multi method render(Str $text, :$status=200) {
        samewith :type<text>, :body($text), :$status
    }

    multi method render(Pair $p) {
        samewith template => $p.key, template_params => $p.value
    }

    multi method render(:$text!, :$status=200) {
        samewith :type<text>, :body($text), :$status
    }

    multi method render(:$json!, :$status=200) {
        my $out = to-json($json);
        samewith :type<json>, :body($out), :$status
    }

    multi method render(:$template!, :$status=200, *%template_params) returns Utiaji::Response {
        my $t = self.load-template($template) or return self.render_not_found;
        %template_params<app> = self;
        samewith :type<html>, :body( $t.render(|%template_params) ), :$status
    }

#    multi method render(:$template!, :%template_params is copy, :$session, :$status=200) {
#        my $t = self.load-template($template) or return self.render_not_found;
#        %template_params<app> = self;
#        samewith :type<html>, :body( $t.render(|%template_params) ), :$status
#    }

    multi method render(:$type='text', :$body='', :$status!) returns Utiaji::Response {
        my $res = Utiaji::Response.new;
        debug "rendering $type";
        $res.headers<content-type> = %mime-types{$type};
        $res.body = ~$body;
        $res.status = $status;
        return $res;
    }

    method load-template($template) {
        my $path = "$.root/$.template-path/$template\.$.template-suffix";
        $path.IO.e or do {
            debug "$path not found";
            return;
        }
        Utiaji::Template.new(cache-key => $path).parse($path.IO.slurp)
    }

}
