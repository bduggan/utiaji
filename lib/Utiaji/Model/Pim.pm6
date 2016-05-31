use Utiaji::DB;
use Utiaji::Log;

class Page {...}
class Day {...}
class AddressBook {...}

role Referencable {
    method refs-in {
        $.db.query: "select f from kk where t=?", self.id;
        return $.db.column;
    }
    method refs-out {
        $.db.query: "select t from kk where f=?", self.id;
        return $.db.column;
    }
    method computed-refs-out {
        ...
    }
}

role Saveable {
    has $.db = Utiaji::DB.new;

    method save {
        self.db.upsertjson( self.id, self.rep );
    }
}

role Serializable {
    method id { ... }
    method rep { ... }
    method rep-ext { ... }
    multi method construct(Str :$id!,:$rep) { ... }
    multi method construct(@pairs) {
        @pairs.map: { self.construct(id => .key, rep => .value) };
    }
}

class Day is Saveable does Serializable does Referencable {
    has Date $.date is required;
    has Str $.text;

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
    method computed-refs-out {
        my @names = ( $!text ~~ m:g/ <?after '@'> \w+ / )».Str;
        return map { Page.new(name => $_).id }, @names;
    }
    method pair {
        return $.date.Str => $.text
    }
}

class Cal {
    has $.db = Utiaji::DB.new;
    has Date $.from;  # start of range
    has Date $.to;    # end of range
    has Day @.days;   # days in range, possibly plus a window before + after
    has Date $!focus = Date.today; # has the year + month of interest

    method align {
         $!from = $!focus.truncated-to("month");
         $!from .= pred until $!from.day==1;
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
            first => [ $!from.year, $!from.month - 1, $!from.day ],
            year => $!focus.year,
            month_index => $!focus.month - 1,
            data => self.as-data
        }
    }
}

class Wiki {
    has $.db = Utiaji::DB.new;

    method page($name is copy) {
        $.db.query("select v::text from kv where k=?","wiki:$name");
        return Page.construct( id => ~$name, rep => $.db.json );
    }

}

class Page does Serializable does Saveable does Referencable {
    has Str $.name is required;
    has Str $.text;

    multi method construct(Str :$id!,:$rep) {
        my $name = $id.subst('wiki:','');
        my $text = $rep<txt> // "";
        return Page.new(name => "$name", text => $text);
        self;
    }

    method id {
        return 'wiki:' ~ $!name
    }
    method rep {
        return { txt => $!text }
    }
    method rep-ext {
        return { txt => self.text, dates => self.refs-in».subst('date:','') }
    }
    method computed-refs-out {
        # TODO: other pages etc
        return ();
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

    multi method save(@resources) {
        self.save($_) for @resources;
    }

}

