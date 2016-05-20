unit class Utiaji::Body;
use JSON::Fast;
use Utiaji::Log;

has $.raw;
has $.parsed;

method parse($!raw) {
    return self;
}

method json {
   return unless $.raw;
   return $!parsed if $!parsed;
   try {
       CATCH { debug "invalid JSON"; .resume }
       $!parsed = from-json($.raw)
   }
   $!parsed;
}
