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
          $res.headers{"Location"} = "/cal";
          $res.status = 302;
      };

    .get: '/cal',
      -> $req,$res {
         self.render: $res,
             'cal' => { tab => "cal", today => "monday" }
    };

    .get: '/wiki',
      -> $req,$res {
         self.render: $res,
             'wiki' => { tab => "wiki" }
    };

    .get: '/wiki/:page',
      -> $req, $res, $/ {
          self.db.query: "select v::text from kv where k=?", "wiki:$<page>";
          my $data = $.db.json;
          self.render: $res, 'wiki' => { tab => "wiki", page => $<page>, data => $data }
    };

    .get: '/people',
      -> $req,$res {
         self.render: $res,
             'people' => { tab => "people" }
    };


}
