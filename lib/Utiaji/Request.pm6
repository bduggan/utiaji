use Utiaji::Log;
use Utiaji::Headers;
use Utiaji::RequestLine;

class Utiaji::Request {
    has Str $.raw;
    has Utiaji::Headers $.headers;
    has Utiaji::RequestLine $.request-line;
    # has Utiaji::Body $.body;

    method verb {
        $.request-line.verb;
    }

    method path {
        $.request-line.path;
    }

    method gist {
        return "{ $.verb // '?' } { $.path // '?' }";
    }

    method parse {
        my ($head,$body) = $.raw.split( / "\n\n" | "\r\n\r\n" /, 2, :skip-empty );
        return unless $head;
        my ($request-line-raw, $headers-raw) = $head.split( / "\n" | "\r\n" /, 2, :skip-empty );
        $!request-line = Utiaji::RequestLine.new(raw => $request-line-raw).parse or return;
        $!headers = Utiaji::Headers.new(raw => $headers-raw).parse;
        return self;
    }

}
