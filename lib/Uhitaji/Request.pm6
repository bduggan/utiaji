use Uhitaji::Log;
use Uhitaji::Headers;
use Uhitaji::RequestLine;
use Uhitaji::Body;

# https://www.w3.org/Protocols/rfc2616/rfc2616.txt
#
# Section 5.
#
#  Request    = Request-Line              ; Section 5.1
#               *(( general-header        ; Section 4.5
#                | request-header         ; Section 5.3
#                | entity-header ) CRLF)  ; Section 7.1
#               CRLF
#               [ message-body ]          ; Section 4.3
#

class Uhitaji::Request {
    has Str $.raw;
    has Uhitaji::RequestLine $.request-line;
    has Uhitaji::Headers $.headers;
    has Uhitaji::Body $.body;

    method verb {
        $.request-line.verb;
    }

    method path {
        $.request-line.path;
    }

    method gist {
        return "{ $.verb // '?' } { $.path // '?' }";
    }

    method json {
        return $.body.json;
    }

    method parse {
        my ($head,$body-raw) = $.raw.split( / "\n\n" | "\r\n\r\n" /, 2, :skip-empty );
        return unless $head;
        my ($request-line-raw, $headers-raw) = $head.split( / "\n" | "\r\n" /, 2, :skip-empty );
        $!request-line = Uhitaji::RequestLine.new(raw => $request-line-raw).parse or return;
        if $$headers-raw.defined {
            $!headers = Uhitaji::Headers.new(raw => $headers-raw).parse
        }
        if $body-raw {
            $!body = Uhitaji::Body.new(raw => $body-raw).parse
        }
        return self;
    }

}
