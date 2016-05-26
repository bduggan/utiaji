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
    has Date $.date;
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
}

class Cal {
    has $.db = Utiaji::DB.new;
    has Date $.from;
    has Date $.to;
    has Day @.days;
    has %.raw;   # map from date strings to date text

    method align {
         $!from = Date.today.truncated-to("month");
         $!from .= pred until $!from.day==1;
         $!to = $!from.later(:6weeks).pred;
         self;
    }

    multi method load(Bool :$window, Str :$from!, Bool :$align) {
        self.load(:$window,from => Date.new($from), :$align);
    }

    multi method load(Bool :$window = False, :$!from = Date.today, :$!to=$!from, Bool :$align = True) {
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
        return
            first => [ $!from.year, $!from.month - 1, $!from.day ],
            year => $!from.year,
            month_index => Date.today.month - 1,
            data => %.raw;
    }

    method update(:$dates) {
       for %$dates.kv -> $k,$v {
           Day.new(k => $k, value => $v).save;
           #self.db.upsertjson( "date:$k", { txt => $v } );
           #my @refs = Wiki.extract-refs($v);
           #say "refs:" ~ @refs.perl;
       }
     }
}

class Wiki {
    has $.db = Utiaji::DB.new;

    # method save_page($page,$json) {
    #     say "called save page";
    #     self.db.query("insert into kv (k,v) values (?,?) on conflict (k) do update set v=?",
    #         "wiki:$page", to-json($json), to-json($json)) or return False;
    #     my @new = self.extract-refs($json<txt>);
    #     say "text is " ~ $json.perl;
    #     say "new refs { @new }";
    #     $.db.query("select t from kk where f=?","wiki:$page") or error $.db.errors;
    #     my @old = $.db.results;
    #     say "new" ~ @new.perl;
    #     say "old" ~ @old.perl;
    #     return True;
    #     #my @add = @new - @old;
    #     #my @del = @old - @new;
    #     #$.db.query: "insert into kv (k) values (?) on conflict (k) do nothing", "wiki:$_" for @add;
    #     #$.db.query: "insert into kk (f,t) values (?,?)", "wiki:$page", $_ for @add;
    #     #$.db.query: "delete from kk where f=?", $_ for @del;
    # }
    #
    method page($page) {
        self.db.query: "select v::text from kv where k=?", "wiki:$page";
        return $.db.json;
    }
}

class Page does Serializable does Saveable does Referencable {
    has Str $.name;
    has $.text;

    method construct(:$k,:$value) {
        my $name = $k.subst('wiki:','');
        return Page.new(name => "$name", text => $value<txt>);
        self;
    }

    method k {
        die "no name for k" unless defined($!name);
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
        $day.save;
        my @computed = $day.computed-refs-out;
        my @existing = $day.refs-out;
        for @computed (-) @existing -> $pair {
            my $to = $pair.key;
            $.db.query: "insert into kv (k) values (?) on conflict (k) do nothing", $to;

            $.db.query: 'insert into kk (f,t) values (?,?)',
                $day.k, $to or return False;
        }
        for @existing (-) @computed -> $pair {
            my $to = $pair.key;
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


