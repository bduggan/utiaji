use Utiaji::Log;
use Utiaji::Headers;
use Utiaji::RequestLine;
use Utiaji::Body;
use Utiaji::Session;

class Utiaji::Request {
    has Str $.raw;
    has Str $.unhandled-message;
    has Utiaji::RequestLine $.request-line handles <verb path query query-params>;
    has Utiaji::Headers $.headers = Utiaji::Headers.new;
    has Utiaji::Body $.body handles <json> = Utiaji::Body.new;
    has Utiaji::Session $.session = Utiaji::Session.new;

    method gist {
        return "{ $.verb // '?' } { $.path // '?' }";
    }

    method param($name) {
        self.query-params{$name}
    }

    method parse {
        my ($head,$body-raw) = $.raw.split( / "\n\n" | "\r\n\r\n" /, 2, :skip-empty );
        return unless $head;
        my ($request-line-raw, $headers-raw) = $head.split( / "\n" | "\r\n" /, 2, :skip-empty );
        $!request-line = Utiaji::RequestLine.new(raw => $request-line-raw).parse or do {
            debug "Did not parse request line: $request-line-raw";
            return;
        };
        if $headers-raw {
            $!headers.parse($headers-raw);
            #if my $session-cookie = $!headers.cookies<utiaji> {
                #    debug "parsing $session-cookie";
                #$!session.parse($session-cookie.value) or debug "invalid session cookie";
                #debug "session values: " ~ $!session.gist;
            #}
        }
        if $body-raw {
            $!body.parse($body-raw);
        }
        return self;
    }

}
