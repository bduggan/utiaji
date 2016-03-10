use HTTP::Tinyish;
use JSON::Fast;
use Test;

BEGIN {
    %*ENV<UTIAJI_LOG_LEVEL> //= 'info';
}

unit class Utiaji::Test;
use Utiaji::Server;

has %.res is rw;
has HTTP::Tinyish $.ua = HTTP::Tinyish.new;
has Utiaji::Server $.server = Utiaji::Server.new;

method get_ok(Str $path) {
    %.res = $.ua.get($.server_url ~ $path);
    isnt %.res<status>, 599, "GET $path";
    self;
}

method status_is(Int $status) {
    is %.res<status>, $status, "status $status";
    self;
}

method content_is(Str $content) {
    is %.res<content>, $content, "Content is $content";
    self;
}

method content_type_is(Str $content_type) {
    is %.res<headers><content-type>, $content_type, "Content type $content_type";
    self;
}

multi method post_ok(Str $path, :$json) {
    %.res = $.ua.post($.server_url ~ $path,
        headers => "Content-type" => 'application/json',
        content => to-json( $json )
    );
    isnt %.res<status>, 599, "POST $path";
    self;
}

multi method post_ok(Str $path, :%headers, Str :$content ) {
    %.res = $.ua.post($.server_url ~ $path,
        headers => %headers,
        content => $content
    );
    isnt %.res<status>, 599, "POST $path";
    self;
}

multi method post_ok(Str $path) {
    %.res = $.ua.post($.server_url ~ $path);
    isnt %.res<status>, 599, "POST $path";
    self;
}

method json_is($json) {
    self.content_type_is('application/json');
    my $json_res;
    try {
        $json_res = from-json(%.res<content>);
        CATCH {
            diag %.res<content>;
            diag .message;
            .resume;
        }
    }
    is-deeply $json, $json_res, "JSON matches";
    self;
}

method server_url {
    $.server.url;
}
