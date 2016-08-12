unit class Utiaji::Session does Associative;

use Digest::HMAC;
use Digest::SHA;
use JSON::Fast;
use Base64;
use Utiaji::Log;
use Utiaji::DateTime;
use Utiaji::Cookie;

%*ENV<UTIAJI_SECRET> //= (^10¹⁰⁰⁰).pick;

has %!fields handles <list kv keys values AT-KEY EXISTS-KEY DELETE-KEY gist>;
has Str:D $.key = %*ENV<UTIAJI_SECRET>;
has $.expiration is rw = 60 * 30;

sub hmac-sha1($str,$key) {
    return hmac-hex($key,$str,&sha1);
}

method Str {
   my $timestamp = now.Int;
   my $json = to-json(%!fields.push( '_ts' => $timestamp ));
   my $sig = hmac-sha1( $json,  self.key );
   return encode-base64("$sig:$json", :str);
}

method parse(Str:D $str) {
   my $both = decode-base64($str, :bin).decode;
   my ($sig,$json) = split ":", $both, 2;
   return unless $sig and $json;
   my $check = hmac-sha1($json, self.key);
   $json = from-json($json);
   return unless $check eq $sig;
   return unless %$json<_ts> ~~ Int;
   my Int $ts = %$json<_ts>:delete;
   return if now.Int - $ts > $.expiration;
   %!fields = %$json;
   return self;
}

method to-cookie {
    my $expires = Utiaji::DateTime.now.later(seconds => $.expiration);
    Utiaji::Cookie.new(:name<utiaji>,
        :value(self.Str),
        :!secure, # TODO
        :max-age($.expiration),
        :expires($expires));
}
