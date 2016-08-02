use v6;
use lib 'lib';
use Test;
use Utiaji::Cookie;

my $cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>, :path</>
    :expires(Utiaji::DateTime.new("2021-01-13T22:23:01Z")),
    :max-age(10234);
ok $cookie.secure, "secure by default";
ok $cookie.http-only,  "http only by default";
is ~$cookie, "monster=mash; Domain=example.com; Path=/; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Max-Age=10234; Secure; HttpOnly", 'encoded';

$cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>, :path</>
    :expires(Utiaji::DateTime.new("2021-01-13T22:23:01Z")),
    :max-age(10234),
    :!secure;
is ~$cookie, "monster=mash; Domain=example.com; Path=/; Expires=Wed, 13 Jan 2021 22:23:01 GMT; Max-Age=10234; HttpOnly", 'encoded';

$cookie = Utiaji::Cookie.new:
    :name<monster>, :value<mash>,
    :domain<example.com>
    :!secure, :!http-only;
is ~$cookie, "monster=mash; Domain=example.com; Path=/", 'encoded';


done-testing;

