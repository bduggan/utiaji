use Utiaji::App;
use Utiaji::Log;
use Utiaji::Model::Pim;

unit class Utiaji::App::Pim is Utiaji::App;

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
         my $cal = $.pim.cal.load;
         self.render: $res,
             'cal' => { tab => "cal", today => "monday", cal => $cal }
    };

    .get: '/cal/range/Δfrom/Δto',
       -> $req, $res, $/ {
         self.render: $res, json => $.pim.cal.load(from => ~$<from>, to => ~$<to>, align => False).as-data;
    };

    .post: '/cal',
      sub ($req, $res) {
          my $json = $req.json or return
              self.render: $res, json => { status => 'error', message => 'no data' };
          $.pim.save: Day.construct: $json<data>.kv.map: { $^k => ( txt => $^v ) }
          self.render: $res, json => { status => 'ok' };
        };

    .get: '/wiki',
      -> $req,$res {
         self.redirect_to: $res, '/wiki/main';
       };

    .get: '/wiki/:page',
      -> $req, $res, $/ {
          my $page = $.pim.wiki.page(~$<page>);
          self.render: $res, 'wiki' => { tab => "wiki", page => $page }
        };

    .get: '/wiki/:page.json',
      -> $req, $res, $/ {
          my $page = $.pim.wiki.page($<page>);
          self.render: $res, json => { txt => $page.text, dates => $page.refs-in».subst('date:','') };
        };

    .post: '/wiki/:page',
       -> $req, $res, $/ {
          my $page = Page.new(name => ~$<page>, text => $req.json<txt>);
          if $.pim.save($page) {
            self.render: $res, json => { 'status' => 'ok' };
        } else {
            self.render: $res, :400status, json => { error => 'cannot save' } ;
        };
       };
    .get: '/people',
      -> $req,$res {
         self.render: $res,
             'people' => { tab => "people" }
        };

}
