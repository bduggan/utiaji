unit class OAuth2::Client::Google;
use IO::Socket::SSL;
use JSON::Fast;

# Reference:
# https://developers.google.com/identity/protocols/OAuth2WebServer

has $.config;
has $.redirect-uri is required;
has $.response-type = 'code';
has $.prompt = 'consent'; #| or none or select_account or "consent select_account";
has $.include-granted-scopes = 'true';
has $.scope = "https://www.googleapis.com/auth/calendar.readonly";
has $.state = "";
has $.login-hint;
has $.access-type; # online offline

method !client-id { $.config<web><client_id> }
method !client-secret { $.config<web><client_secret> }
method !parse-response($str,$encoding) {
    my ($head, $body) = split rx{\r\n\r\n}, $str, 2;
    my $content;
    if $head ~~ /'Transfer-Encoding: chunked'/ {
        my @lines = split rx{\r\n}, $body;
        loop {
            my $len = :16(shift @lines) or last;
            my $chunk = shift @lines;
            while $chunk.encode($encoding).bytes < $len {
                $chunk ~= "\r\n";
                $chunk ~= shift @lines;
            }
            $content ~= $chunk;
            last unless @lines;
        }
    } else {
        $content = $body;
    }
    return from-json($content);
}

method !generate-access-token-request(%values) {
    my $body = %values.map({ "{.key}={.value}" }).join('&');
    my $length = $body.encode('UTF-8').bytes;
    my $req = qq:to/HTTP_REQUEST/;
       POST /oauth2/v4/token HTTP/1.1
       Host: www.googleapis.com
       Content-Type: application/x-www-form-urlencoded
       Content-Length: $length

       $body
       HTTP_REQUEST
    return $req;
}

method auth-uri {
    my $web-config = $.config<web>;
    die "missing client_id" unless $web-config<client_id>;
    return $web-config<auth_uri> ~ '?' ~
     (

         response_type          => $.response-type,
        client_id              => self!client-id,
        redirect_uri           => $.redirect-uri,
        scope                  => $.scope,
        state                  => $.state,
        access_type            => $.access-type,
        prompt                 => $.prompt,
        login_hint             => $.login-hint,
        include_granted_scopes => $.include-granted-scopes,
     ).map({ "{.key}={.value}" }).join('&');
}

#| Send a request to <https://www.googleapis.com/oauth2/v4/token>.
#|
#| Returns:
#|
#| access_token  The token that can be sent to a Google API.
#| refresh_token A token that may be used to obtain a new access
#|                 token. Refresh tokens are valid until the user revokes access.
#|                 This field is only present if access_type=offline is included
#!                 in the authorization code request.
#| expires_in 	 The remaining lifetime of the access token.
#| token_type 	 Identifies the type of token returned.
#|                 At this time, this field will always have the value Bearer.
method code-to-token(:$code!) {
    my %payload =
        code => $code,
        client_id => self!client-id,
        client_secret => self!client-secret,
        redirect_uri => $.redirect-uri,
        grant_type => 'authorization_code';
    my $req = self!generate-access-token-request(%payload);
    my $ssl = IO::Socket::SSL.new(:host<www.googleapis.com>, :port<443>);
    $ssl.print($req) or return;
    my $res = $ssl.recv;
    return self!parse-response($res,$ssl.encoding);
}

