use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;
use Utiaji::Model::Pim;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;
has $.template-path = 'templates/pim';
has $.pim = Utiaji::Model::Pim.new;

method BUILD {
    $_ = self.router;

    .get: '/',
      -> $req, $res {
          self.redirect_to: $res, '/cal';
     };

    .get: '/cal',
      -> $req,$res {
         my %events = $.pim.cal.initial_state;
         self.render: $res,
             'cal' => { tab => "cal", today => "monday", data => %events }
    };

    .get: '/cal/range/Δfrom/Δto',
       -> $req, $res, $/ {
         self.render: $res, json => $.pim.cal.events($<from>, $<to>);
    };

    .post: '/cal',
      sub ($req, $res) {
          my $json = $req.json or return
              self.render: $res, json => { status => 'error', message => 'no data' };
          $.pim.cal.update(dates => $json<data> || {});
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
