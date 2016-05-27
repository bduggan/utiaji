use Utiaji::DB;
use Utiaji::Log;

class Page {...}
class Day {...}
class AddressBook {...}

role Referencable {
    method refs-in {
        $.db.query: "select f from kk where t=?", self.k;
        return $.db.column;
    }
    method refs-out {
        $.db.query: "select t from kk where f=?", self.k;
        return $.db.column;
    }
    method computed-refs-out {
        ...
    }
}

role Saveable {
    has $.db = Utiaji::DB.new;

    method save {
        self.db.upsertjson( self.k, self.value );
    }
}

role Serializable {
    method k { ... }
    method value { ... }
    multi method construct(Str :$k!,:$value) { ... }
    multi method construct(@pairs) {
        @pairs.map: { self.construct(k => .key, value => .value) };
    }
}

class Day is Saveable does Serializable does Referencable {
    has Date $.date is required;
    has Str $.text;

    submethod BUILD(:$date,:$text) {
        $!text = $text if $text.defined;
        $!date = Date.new($date) if $date.isa('Str')
    }
    multi method construct(Str :$k!,:$value = { txt => ""}) {
        Day.new( date => $k.subst('date:', ''), text => $value<txt>.Str // "");
    }
    method k {
        return 'date:' ~ $.date.Str;
    }
    method value {
        return { txt => $.text }
    }
    method computed-refs-out {
        my @names = ( $!text ~~ m:g/ <?after '@'> \w+ / )».Str;
        return map { Page.new(name => $_).k }, @names;
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

    multi method load( :$month!, :$year!) {
        $!focus = Date.new(sprintf("%04d-%02d-01",$year,$month));
        self.load(:window, :align, from => $!focus, :to($!focus.later(:1month)));
    }

    multi method load(Bool :$window, Str :$from!, Bool :$align) {
        self.load(:$window,from => Date.new($from), :$align);
    }

    multi method load(Bool :$window = False, :$!from = $!focus, :$!to=$!from, Bool :$align = True) {
        self.align if $align;
        my ($from,$to) = ($!from,$!to);
        if ($window) {
            $from.= earlier(:12weeks);
            $to.= later(:12weeks);
        }
        $.db.query: "select k,v::text from kv where k >= ? and k <= ?", "date:$from", "date:$to";
        @!days = map { Day.construct(k => .[0], value => .[1]) }, $.db.jsonv;
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

    method make-days(:$dates) {
        return Day.construct: %$dates.kv.map: { $^k => ( txt => $^v ) }
     }
}

class Wiki {
    has $.db = Utiaji::DB.new;

    method page($name is copy) {
        $.db.query("select v::text from kv where k=?","wiki:$name");
        return Page.construct( k => ~$name, value => $.db.json );
    }

}

class Page does Serializable does Saveable does Referencable {
    # 'content' in html is 'text' in object, is 'txt' in db
    has Str $.name is required;
    has Str $.text;

    multi method construct(Str :$k!,:$value) {
        my $name = $k.subst('wiki:','');
        my $text = $value<txt> // "";
        return Page.new(name => "$name", text => $text);
        self;
    }

    method k {
        return 'wiki:' ~ $!name
    }
    method value {
        return { txt => $!text }
    }
    method computed-refs-out {
        # TODO: other pages etc
        return ();
    }

    method initial-state {
        my %state = text => $!text // "";
        return %state;
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
        $resource.save or return False;
        my @computed = $resource.computed-refs-out;
        my @existing = $resource.refs-out;
        for ( @computed (-) @existing ).keys -> $to {
            $.db.query: "insert into kv (k) values (?) on conflict (k) do nothing", $to;
            $.db.query: 'insert into kk (f,t) values (?,?)', $resource.k, $to or return False;
        }
        for ( @existing (-) @computed ).keys -> $to {
            $.db.query: 'delete from kk where f=? and t=?',
                $resource.k, $to or return False;
        }
        return True;
    }

    multi method save(@resources) {
        self.save($_) for @resources;
    }

}


