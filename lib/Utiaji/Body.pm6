unit class Utiaji::Body;
use JSON::Fast;

has $.raw;

method parse($!raw) {
    return self;
}

method json {
   return unless $.raw;
   from-json($.raw)
}
