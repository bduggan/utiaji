use Utiaji::DB;
use Utiaji::Log;

class Page {...}
class Day {...}
class AddressBook {...}

role Referencable { ... }
role Serializable { ... }
role Searchable { ... }

enum resource <page date person>;

role Referencable {
    method id { ... }
    method text { ... }
    method label { ... }
    method href { ... }
    sub links($text) {
        return unless $text;
        return ( $text ~~ m:g/ <?after '@'> \w+ / )».Str;
    }
    method refs-in(resource $type, Bool :$ids) {
        $.db.query: "select f from kk where t=? and f like ?", self.id, "$type:%";
        my @results = $.db.column;
        return @results unless $ids;
        return @results».subst("$type:","")
    }
    method refs-out {
        $.db.query: "select t from kk where f=?", self.id;
        return $.db.column;
    }
    method computed-refs-out {
        return () unless $.text;
        my @links = links($.text) or return ();
        return map { Page.new(name => $_).id }, @links;
    }
}

role Saveable {
    #| Saveable things have ids, representations, and the ability to be saved and reconstructed.
    method db {
        state $db //= Utiaji::DB.new;
        return $db;
    }

    method id { ... }
    method rep { ... }
    method save {
        self.db.upsertjson( self.id, self.rep );
    }
    multi method construct(Str :$id!,:$rep) { ... }
    multi method construct(@pairs) {
        @pairs.map: { self.construct(id => .key, rep => .value) };
    }
}

role Serializable {
    #| Serializable things have external representations.
    method rep-ext { ... }
}

role Searchable {
    method search(Str $query) { ...  }
}

class Day does Saveable does Serializable does Referencable {
    has Date $.date is required;
    has Str $.text;

    method label {
        $.date;
    }
    method href {
        "/cal/" ~ $.date.Str;
    }
    submethod BUILD(:$date,:$text) {
        $!text = $text if $text.defined;
        $!date = Date.new($date) if $date.isa('Str')
    }
    multi method construct(Str :$id!,:$rep = { txt => ""}) {
        Day.new( date => $id.subst('date:', ''), text => $rep<txt>.Str // "");
    }
    method id {
        return 'date:' ~ $.date.Str;
    }
    method rep {
        return { txt => $.text }
    }
    method rep-ext {
        return { txt => $.text }
    }
    method pair {
        return $.date.Str => $.text
    }
}

class Cal {
    enum days «:monday(1) tuesday wednesday thursday friday saturday sunday»;

    has $.db = Utiaji::DB.new;
    has Date $.from;  # start of range
    has Date $.to;    # end of range
    has Day @.days;   # days in range, possibly plus a window before + after
    has Date $!focus = Date.today; # has the year + month of interest

    method align {
         $!from = $!focus.truncated-to("month");
         $!from .= pred until $!from.day-of-week==sunday;
         $!to = $!from.later(:6weeks).pred;
         self;
    }

    multi method load( :$focus! ) {
        $!focus = $focus ~~ Str ??  Date.new($focus) !! $focus;
        self.load( month => $!focus.month, year => $!focus.year );
    }
    multi method load( Int :$month!, Int :$year!) {
        $!focus = Date.new(sprintf("%04d-%02d-01",$year,$month));
        self.load(:window, :align, from => $!focus, :to($!focus.later(:1month)));
    }

    multi method load(Bool :$window, Str :$from!, Str :$to, Bool :$align) {
        self.load(:$window,from => Date.new($from), :$align) unless $to;
        self.load(:$window,from => Date.new($from), to => Date.new($to), :$align);
    }

    multi method load(Bool :$window = False, :$!from = $!focus, :$!to = $!from, Bool :$align = True) {
        self.align if $align;
        my ($from,$to) = ($!from,$!to);
        if ($window) {
            $from.= earlier(:12weeks);
            $to.= later(:12weeks);
        }
        $.db.query: "select k,v::text from kv where k >= ? and k <= ?", "date:$from", "date:$to";
        @!days = map { Day.construct(id => .[0], rep => .[1]) }, $.db.jsonv;
        self;
    }

    method as-data {
        return @.days».pair.Hash;
    }

    method initial-state {
        return {
            first => [ $!from.year, $!from.month, $!from.day ],
            year  => $!focus.year,
            month => $!focus.month,
            data  => self.as-data
        }
    }
}

class Wiki does Searchable {
    has $.db = Utiaji::DB.new;

    method page($name is copy) {
        $.db.query("select v::text from kv where k=?","page:$name");
        return Page.construct( id => ~$name, rep => $.db.json );
    }

    method search(Str $query) {
        $.db.query(q:to/SQL/,"page:%", "page:%$query%", "%$query%");
        select k,v::text from kv
        where k like ?
               and ( ( k like ? and v is not null )
                     or (v->>'txt')::text like ?)
        SQL
        return $.db.jsonv.map: { Page.construct(id => .[0], rep => .[1]) };
    }
}

class Page does Serializable does Saveable does Referencable {
    has Str:D $.name is required;
    has Str $.text;

    method label {
        $.name;
    }
    method href {
        "/wiki/" ~ $.name;
    }
    multi method construct(Str :$id!,:$rep) {
        my $name = $id.subst('page:','');
        my $text = $rep<txt> // "";
        return Page.new(name => "$name", text => $text);
    }

    method id {
        die 'no name' unless $!name;
        return 'page:' ~ $!name
    }
    method rep {
        return { txt => $!text }
    }
    method rep-ext {
        return {
            name => self.name,
            txt => self.text,
            dates => self.refs-in(date, :ids),
            pages => self.refs-in(page, :ids),
        }
    }
    method initial-state {
        return self.rep-ext;
    }
}

class AddressBook {
    has @.people;
}

class Utiaji::Model::Pim {
    has $.db = Utiaji::DB.new;
    has $.cal = Cal.new;
    has $.wiki handles 'page' = Wiki.new;
    has $.addressbook = AddressBook.new;

    multi method save($resource) {
        debug "saving $resource";
        $resource.save or return False;
        my @computed = $resource.computed-refs-out;
        my @existing = $resource.refs-out;
        for ( @computed (-) @existing ).keys -> $to {
            debug "saving ref $to";
            $.db.query: "insert into kv (k) values (?) on conflict (k) do nothing", $to;
            $.db.query: 'insert into kk (f,t) values (?,?)', $resource.id, $to or return False;
        }
        for ( @existing (-) @computed ).keys -> $to {
            debug "removing ref $to";
            $.db.query: 'delete from kk where f=? and t=?',
                $resource.id, $to or return False;
        }
        return True;
    }

    method all-page-names() {
        self.db.query: "select k from kv where k like 'page:%' order by k";
        return self.db.results».subst('page:','');
    }

    multi method save(@resources) {
        self.save($_) for @resources;
    }

    method search(Str $query) {
        return self.wiki.search($query).flat;
    }
}

