use Utiaji::Log;

unit class Utiaji::Headers;

has $.raw;
has %.fields;
has Str $.content-type;
has Int $.content-length;

grammar parser {
     rule TOP {
        [ <header> \n ]*
     }
     token ws { \h* }
     rule header {
        <field-name> ':' <field-value>
     }
     token field-name {
         <-[:]>+
     }
     token field-value {
         <-[\n\r]>+
     }
}

class actions {
    method TOP($/) {
        $/.make: Utiaji::Headers.new:
        fields => [ map {.made }, $<header> ]
    }
    method header($/) {
        $/.make: $<field-name>.made => $<field-value>.made
    }
    method path($/) { $/.make: ~$/; }
    method verb($/) { $/.make: ~$/; }
    method field-name($/) { $/.make: ~$/ }
    method field-value($/) { $/.make: ~$/ }
}

method host {
    return %!fields<Host>;
}

method normalize {
    for %!fields.kv -> $k, $v {
        if fc($k) eq fc('content-length') {
            $!content-length = 0+$v;
        }
    }
}

method parse {
    my $actions = actions.new;
    my $match = parser.parse("$!raw\n", :$actions);
    unless $match {
        error "did not parse headers { $!raw.perl }";
        return;
    }
    my $request = $match.made;
    $request.normalize;
    return $request;
}


