unit class Utiaji::Headers does Associative;
use Utiaji::Log;

# See https://doc.perl6.org/language/subscripts#Custom_type_example
subset StrOrInt where Str | Int;

has $.raw;
has %!fields of StrOrInt handles <list kv keys values>;

my grammar parser {
     rule TOP { [ <header> \n ]* }
     token ws { \h* }
     rule header { <field-name> ':' <field-value> }
     token field-name { <-[:]>+ }
     token field-value { <-[\n\r]>+ }
}

my class actions {
    # see http://docs.perl6.org/language/grammars
    method TOP($/) {
        $/.make: $<header>».made
    }
    method header($/) {
        $/.make: $<field-name>.made => $<field-value>.made
    }
    method field-name($/) { $/.make: ~$/ }
    method field-value($/) { $/.make: ~$/ }
}

# TODO: exceptions: Content-MD5, DNT
sub normalize-key ($key) { $key.subst(/\w+/, *.tc, :g) }
method AT-KEY     ($key) is rw { %!fields{normalize-key $key}        }
method EXISTS-KEY ($key)       { %!fields{normalize-key $key}:exists }
method DELETE-KEY ($key)       { %!fields{normalize-key $key}:delete }
method push (*@list) {
    for @list -> $p {
        self{ $p.key } = $p.value;
    }
}

method parse {
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

