unit class Utiaji::Cookie;
use Utiaji::DateTime;

subset GlutenFree of Str where * ~~ /^ <[\c[33] .. \c[127]] - [,"';\\]>+ $/;

has GlutenFree $.name is required;
has GlutenFree $.value = "";
has Str $.domain is required;
has Str $.path = '/';
has Utiaji::DateTime $.expires;
has Int $.max-age;
has Bool $.http-only = True;
has Bool $.secure = True;

method Str {
    return join '; ', (
           "{$.name}={$.value}",
           "Domain={$.domain}",
           "Path={$.path}",
        |( "Expires={$.expires}" xx $.expires.Bool ),
        |( "Max-Age={$.max-age}" xx $.max-age.Bool ),
        |( "Secure"              xx $.secure ),
        |( "HttpOnly"            xx $.http-only ),
    );
}
