unit class Hamna::Body;
use JSON::Fast;

has $.raw;


method parse {
    return self;
}

method json {
   # TODO memoize
   from-json($.raw)
}
