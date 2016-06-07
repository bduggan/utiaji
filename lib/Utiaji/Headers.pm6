unit class Utiaji::Headers does Associative;
use Utiaji::Log;

# https://doc.perl6.org/language/subscripts#Custom_type_example
# http://tools.ietf.org/html/rfc7230#section-3
subset StrOrInt where Str | Int;

has $.raw;
has %!fields of StrOrInt handles <list kv keys values>;

my grammar parser {
     rule TOP { [ <header> \n ]* }
     token ws { \h* }
     rule header { <field-name> ':' <field-value> }
     token field-name { <-[:]>+ }
     token field-value { <-[\n\r]>* }
}

my class actions {
    method TOP($/) {
        $/.make: $<header>».made
    }
    method header($/) {
        $/.make: $<field-name>.made => $<field-value>.made
    }
    method field-name($/) { $/.make: ~$/ }
    method field-value($/) { $/.make: ~$/ }
}


sub normalize-key ($key) {
    return "Content-MD5" if $key ~~ m:i/^ 'content-md5' $/;
    return "DNT"         if $key ~~ m:i/^  DNT          $/;
    return $key.subst(/\w+/, *.tc, :g);
}

multi method normalize-value("Content-Type", $value) {
    return $value if $value ~~ /charset/;
    return $value ~ '; charset=utf-8';
}
multi method normalize-value($key, $value) {
    return $value;
}

method AT-KEY     ($key) is rw { %!fields{normalize-key $key}        }
method EXISTS-KEY ($key)       { %!fields{normalize-key $key}:exists }
method DELETE-KEY ($key)       { %!fields{normalize-key $key}:delete }
method push (*@list) {
    for @list -> $p {
        self{ $p.key } = $p.value;
    }
}

method parse($!raw) {
    my $actions = actions.new;
    my $match = parser.parse("$!raw\n", :$actions);
    unless $match {
        error "did not parse headers { $!raw.perl }";
        return;
    }
    for $match.made -> $p {
        self.push: $p
    }
    self
}

method Str {
    %!fields
      .pairs
      .map({ .key ~ ': ' ~ self.normalize-value(.key,.value)})
      .join("\r\n");
}
