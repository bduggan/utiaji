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
         my %events = $.pim.cal.load(window => True).initial_state;
         self.render: $res,
             'cal' => { tab => "cal", today => "monday", data => %events }
    };

    .get: '/cal/range/Δfrom/Δto',
       -> $req, $res, $/ {
         self.render: $res, json => $.pim.cal.load(from => $<from>, to => $<to>, align => False).raw;
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
          my $page = $.pim.wiki.page($<page>);
          say "sending data: { $page.perl }";
          self.render: $res, 'wiki' => { tab => "wiki", page => ~$<page>, data => $page }
        };

    .get: '/wiki/:page.json',
      -> $req, $res, $/ {
          self.render: $res, json => $.pim.wiki.page($<page>);
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
