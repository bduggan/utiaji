unit class OAuth2::Client::Google;
use IO::Socket::SSL;

# Reference:
# https://developers.google.com/identity/protocols/OAuth2WebServer

has $.config;
has $.redirect-uri is required;
has $.response-type = 'code';
has $.prompt = 'consent';
has $.include-granted-scopes = 'true';
has $.scope = "https://www.googleapis.com/auth/calendar.readonly";
has $.state = "";

method !client-id { $.config<web><client_id> }
method !client-secret { $.config<web><client_secret> }

method auth-uri {
    my $web-config = $.config<web>;
    die "missing client_id" unless $web-config<client_id>;
    return $web-config<auth_uri> ~ '?' ~
     (  client_id              => self!client-id,
        scope                  => $.scope,
        state                  => $.state,
        redirect_uri           => $.redirect-uri,
        response_type          => $.response-type,
        prompt                 => $.prompt,
        include_granted_scopes => $.include-granted-scopes,
     ).map({ "{.key}={.value}" }).join('&');
}

method code-to-token(:$code!) {
    # go to https://www.googleapis.com/oauth2/v4/token
    my %payload =
        code => $code,
        client_id => self!client-id,
        client_secret => self!client-secret,
        redirect_uri => $.redirect-uri,
        grant_type => 'authorization_code';
    my $body = %payload.map({ "{.key}={.value}" }).join('&');
    my $length = $body.encode('UTF-8').bytes;
    my $req = qq:to/HTTP_REQUEST/;
       POST /oauth2/v4/token HTTP/1.1
       Host: www.googleapis.com
       Content-Type: application/x-www-form-urlencoded
       Content-Length: $length

       $body
       HTTP_REQUEST
    my $ssl = IO::Socket::SSL.new(:host<www.googleapis.com>, :port<443>);
    my $res;
    if ($ssl.print($req)) {
        $res = $ssl.recv;
    }
#        returns:
#    access_token 	The token that can be sent to a Google API.
#    refresh_token 	A token that may be used to obtain a new access token. Refresh tokens are valid until the user revokes access. This field is only present if access_type=offline is included in the authorization code request.
#    expires_in 	The remaining lifetime of the access token.
#    token_type 	Identifies the type of token returned.
#     At this time, this field will always have the value Bearer.
    return $res;
}


