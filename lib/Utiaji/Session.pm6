unit class Utiaji::Session does Associative;

use Digest::HMAC;
use Digest::SHA;
use JSON::Fast;
use Base64;

has %!fields handles <list kv keys values AT-KEY EXISTS-KEY DELETE-KEY>;
has Str $.key is required;
has $.expiration = 300;

sub hmac-sha1($str,$key) {
    return hmac-hex($key,$str,&sha1);
}

method Str {
   my $timestamp = now.Int;
   my $json = to-json(%!fields.append('_ts' => $timestamp));
   my $sig = hmac-sha1( $json,  self.key );
   return encode-base64("$sig:$json").join('');
}

method parse($str) {
   my $both = decode-base64($str)».chr.join("");
   my ($sig,$json) = split ":", $both, 2;
   return unless $sig and $json;
   my $check = hmac-sha1($json, self.key);
   $json = from-json($json);
   return unless $check eq $sig;
   my Int $ts = %$json<_ts>:delete;
   return if now.Int - $ts > $.expiration;
   %!fields = %$json;
   return self;
}
