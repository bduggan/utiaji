use Utiaji::DB;
use Utiaji::Log;

class Page {...}
class Day {...}

role Referencable {
    method refs-in {
        $.db.query: "select f from kk where t=?", self.k;
        return $.db.results;
    }
    method refs-out {
        $.db.query: "select t from kk where f=?", self.k;
        return $.db.results;
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
    method construct(:$k,:$value) { ... }
}

class Day is Saveable does Serializable does Referencable {
    has Date $.date is required;
    has Str $.text;

    submethod BUILD(:$date,:$!text) {
        $!date = Date.new($date) if $date.isa('Str')
    }
    method construct(:$k,:$value = { txt => ""}) {
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
    has Date $.from;
    has Date $.to;
    has Day @.days;
    has Date $!focus = Date.today; # year + month

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

    method initial_state {
        my %data = map { .pair }, @.days;
        return
            first => [ $!from.year, $!from.month - 1, $!from.day ],
            year => $!focus.year,
            month_index => $!focus.month - 1,
            data => %data
    }

    method update(:$dates) {
       for %$dates.kv -> $k,$v {
           Day.new(k => $k, value => $v).save;
       }
     }
}

class Wiki {
    has $.db = Utiaji::DB.new;

    method page($page) {
        self.db.query: "select v::text from kv where k=?", "wiki:$page";
        return $.db.json;
    }
}

class Page does Serializable does Saveable does Referencable {
    has Str $.name is required;
    has $.text;

    method construct(:$k,:$value) {
        my $name = $k.subst('wiki:','');
        return Page.new(name => "$name", text => $value<txt>);
        self;
    }

    method k {
        return 'wiki:' ~ $!name
    }
    method value {
        return { txt => $!text }
    }
    method computed-refs-out {
        # TODO: dates in a page
        return;
    }
}

class AddressBook {
    has @.people;
}

class Utiaji::Model::Pim {
    has $.db = Utiaji::DB.new;
    has $.cal = Cal.new;
    has $.wiki = Wiki.new;
    has $.addressbook = AddressBook.new;

    multi method save(Day :$day) {
        $day.save or return False;
        my @computed = $day.computed-refs-out;
        my @existing = $day.refs-out;
        for ( @computed (-) @existing ).keys -> $to {
            $.db.query: "insert into kv (k) values (?) on conflict (k) do nothing", $to;
            $.db.query: 'insert into kk (f,t) values (?,?)', $day.k, $to or return False;
        }
        for ( @existing (-) @computed ).keys -> $to {
            $.db.query: 'delete from kk where f=? and t=?',
                $day.k, $to or return False;
        }
        return True;
    }
    method days() { ... }

    method page(Str $name) {
        $.db.query("select v->>'txt' from kv where k=?",$name);
        return Page.new( name => $name, text => $.db.result ) ;
    }

}


