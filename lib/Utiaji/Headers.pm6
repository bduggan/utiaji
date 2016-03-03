use Utiaji::Log;

unit class Utiaji::Headers;

has $.raw;
has %.fields;

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
    has Utiaji::Headers $.made;
    method TOP($/) {
        $.made.fields = [ map {.made }, $<header> ]
    }
    method header($/) {
        $/.make: $<field-name>.made => $<field-value>.made
    }
    method path($/) { $/.make: ~$/; }
    method verb($/) { $/.make: ~$/; }
    method field-name($/) { $/.make: ~$/ }
    method field-value($/) { $/.make: ~$/ }
}


method normalize {
    my %new;
    for %!fields.kv -> $k, $v {
        %new{lc $k} = $v;
    }
    %!fields = %new;
}

method content-type { %!fields<content-type> }
method content-length { %!fields<content-length> }
method host { %!fields<host>; }


method parse {
    my $actions = actions.new(made => self);
    my $match = parser.parse("$!raw\n", :$actions);
    unless $match {
        error "did not parse headers { $!raw.perl }";
        return;
    }
    self.normalize;
    self
}

