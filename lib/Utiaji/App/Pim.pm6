use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;
has $.template-path = 'templates/pim';

method BUILD {
    $_ = self.router;

    .get: '/',
      -> $req, $res {
          self.redirect_to: $res, '/cal';
      };

    .get: '/cal',
      -> $req,$res {
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
         self.render: $res,
             'cal' => { tab => "cal", today => "monday", data => %data }
    };
    .get: '/cal/range/Δfrom/Δto',
       -> $req, $res, $/ {
         debug "calling query";
         $.db.query: "select k,v->>'txt' from kv where k >= ? and k <= ?", "date:$<from>", "date:$<to>";
         my %results = map { .[0].subst('date:','') => .[1] }, $.db.results;
         self.render: $res, json => %results;
    };
    .post: '/cal',
      sub ($req, $res) {
          my $json = $req.json or return
              self.render: $res, json => { status => 'error', message => 'no data' };
          my $dates = $json<data> // {};
          for %$dates.kv -> $k,$v {
              self.db.upsertjson( "date:$k", { txt => $v } );
          }
          self.render: $res, json => { status => 'ok' };
      };

    .get: '/wiki',
      -> $req,$res {
         self.redirect_to: $res, '/wiki/main';
    };

    .get: '/wiki/:page',
      -> $req, $res, $/ {
          self.db.query: "select v::text from kv where k=?", "wiki:$<page>";
          my $data = $.db.json;
          self.render: $res, 'wiki' => { tab => "wiki", page => $<page>, data => $data }
    };

    .post: '/wiki/:page',
       -> $req, $res, $/ {
          my $json = $req.json;
          self.db.query: "delete from kv where k=? ", "wiki:$<page>";
          self.db.query: "insert into kv (k,v) values (?,?)", "wiki:$<page>", :$json;
          self.render: $res, json => { 'status' => 'ok' };
    };

    .get: '/people',
      -> $req,$res {
         self.render: $res,
             'people' => { tab => "people" }
    };

}
