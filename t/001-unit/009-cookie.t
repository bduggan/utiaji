use v6;
use lib 'lib';
use Test;
use Utiaji::Cookie;

my $cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>, :path</>
    :expires(Utiaji::DateTime.new("2021-01-13T22:23:01Z")),
    :secure,
    :http-only,
    :max-age(10234);
ok $cookie.secure, "secure";
ok $cookie.http-only,  "http only";
is ~$cookie, "monster=mash; Path=/; Domain=example.com; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Max-Age=10234; Secure; HttpOnly", 'encoded';

$cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>, :path</>
    :expires(Utiaji::DateTime.new("2021-01-13T22:23:01Z")),
    :max-age(10234),
    :!secure;
is ~$cookie, "monster=mash; Path=/; Domain=example.com; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Max-Age=10234; HttpOnly", 'encoded';

$cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>
    :!secure, :!http-only;
is ~$cookie, "monster=mash; Path=/; Domain=example.com", 'encoded';


done-testing;

