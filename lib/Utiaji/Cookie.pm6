unit class Utiaji::Cookie;
use Utiaji::DateTime;

subset GlutenFree of Str where * ~~ /^ <[\c[33] .. \c[127]] - [,"';\\]>+ $/;

has GlutenFree $.name is required;
has GlutenFree $.value = "";
has Str $.domain;
has Str $.path = '/';
has Utiaji::DateTime $.expires;
has Int $.max-age;
has Bool $.http-only = True;
has Bool $.secure = False;  # TODO change

method Str {
    return join '; ', (
           "{$.name}={$.value}",
           "Path={$.path}",
        |( "Domain={$.domain}"   xx $.domain.Bool ),
        |( "Expires={$.expires}" xx $.expires.Bool ),
        |( "Max-Age={$.max-age}" xx $.max-age.Bool ),
        |( "Secure"              xx $.secure ),
        |( "HttpOnly"            xx $.http-only ),
    );
}
