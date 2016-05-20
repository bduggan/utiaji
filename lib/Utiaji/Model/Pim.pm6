use Utiaji::DB;

class Cal {
    has $.db = Utiaji::DB.new;
    method initial_state {
         my $f = Date.today.truncated-to("month");
         $f .= pred until $f.day==1;
         $.db.query: "select k,v->>'txt' from kv where k >= ? and k <= ?",
            "date:{ $f.earlier(:6weeks) }", "date:{ $f.later(:6weeks) }";
         my %events = map { .[0].subst('date:','') => .[1] }, $.db.results;
         my %data =
            first => [ $f.year, $f.month - 1, $f.day ],
            year => $f.year,
            month_index => Date.today.month - 1,
            data => %events;
        return %data;
    }
    method events($from,$to) {
         $.db.query: "select k,v->>'txt' from kv where k >= ? and k <= ?", "date:$from", "date:$to";
         my %results = map { .[0].subst('date:','') => .[1] }, $.db.results;
         return %results;
    }
    method update(:$dates) {
       for %$dates.kv -> $k,$v {
           self.db.upsertjson( "date:$k", { txt => $v } );
       }
     }

}

class Wiki {
    has $.db = Utiaji::DB.new;

    method save_page($page,$json) {
        self.db.query: "delete from kv where k=? ", "wiki:$page";
        self.db.query: "insert into kv (k,v) values (?,?)", "wiki:$page", :$json;
    }

    method page_text($page) {
        self.db.query: "select v::text from kv where k=?", "wiki:$page";
        return $.db.json;
    }
}

class AddressBook {

}

class Utiaji::Model::Pim {
    has $.db = Utiaji::DB.new;
    has $.cal = Cal.new;
    has $.wiki = Wiki.new;
    has $.addressbook = AddressBook.new;

}


