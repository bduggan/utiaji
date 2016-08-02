unit class Utiaji::Cookie;
use Utiaji::DateTime;

has Str $.name is required;
has Str $.value = "";
has Str $.domain is required;
has Str $.path = '/';
has Utiaji::DateTime $.expires;
has Int $.max-age;
has Bool $.http-only = True;
has Bool $.secure = True;

method Str {
    return join '; ', (
        $.name ~ '=' ~ $.value,
        "Domain=" ~ $.domain,
        "Path=" ~ $.path,
        "Expires=" ~ $.expires,
        "Max-Age=" ~ $.max-age,
        "Secure" x $.secure,
        "HttpOnly" x $.http-only,
    );
}
