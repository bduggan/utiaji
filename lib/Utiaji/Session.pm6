unit class Utiaji::Session does Associative;

use Digest::HMAC;
use Digest::SHA;
use JSON::Fast;
use Base64;
use Utiaji::Log;

warn "please set UTIAJI_SECRET" unless %*ENV<UTIAJI_SECRET>;

has %!fields handles <list kv keys values AT-KEY EXISTS-KEY DELETE-KEY gist>;
has Str:D $.key = %*ENV<UTIAJI_SECRET> // "not very secret";
has $.expiration = 60 * 30;

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
   say "no sig" unless $sig;
   say "no json" unless $json;
   return unless $sig and $json;
   my $check = hmac-sha1($json, self.key);
   $json = from-json($json);
   return unless $check eq $sig;
   debug $json.perl;
   return unless %$json<_ts> ~~ Int;
   my Int $ts = %$json<_ts>:delete;
   return if now.Int - $ts > $.expiration;
   %!fields = %$json;
   return self;
}

