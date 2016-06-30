use Utiaji::App;
use Utiaji::Log;
use Utiaji::Model::Pim;

unit class Utiaji::App::Pim is Utiaji::App;

has $.template-path = 'templates/pim';
has $.pim = Utiaji::Model::Pim.new;

method setup {
    $_ = self;
    .get: '/', { self.redirect_to: $^res, '/wiki' }

    .get: '/cal', {
            my $cal = self.pim.cal.load;
            self.render: $^res, 'cal' => { :tab<cal>, :cal($cal) }
    }

    .get: '/cal/Δday',
        -> $req, $res, $/ {
            my $cal = self.pim.cal.load(focus => ~$<day>);
            self.render: $res, 'cal' => { :tab<cal>, :cal($cal)}
    }

    .get: '/cal/range/Δfrom/Δto', -> $res, $/ {
            self.render: $res,
                json => self.pim.cal.load(from => ~$<from>,
                        to => ~$<to>, :!align, :!window).as-data;
    }

    .post: '/cal', {
            my $json = $^req.json or return
                self.render: $^res, json => { status => 'error',
                    message => 'no data' };
            my $data = $json<data>
                   or return self.render: $^res,
                        json => { error => 'missing data', :400status };
            self.pim.save: Day.construct: $json<data>.kv.map: { $^k => ( txt => $^v ) }
            self.render: $^res, json => { status => 'ok' };
    }

    .get: '/wiki', { self.redirect_to: $^res, '/wiki/main' }

    .get: '/wiki/:page',
        -> $req, $res, $/ {
            my $page = self.pim.wiki.page(~$<page>);
            self.render: $res, 'wiki' => { :tab<wiki>, :page($page)}
    }

    .get: '/wiki/:page.json',
        -> $req, $res, $/ {
            my $page = self.pim.wiki.page($<page>);
            self.render: $res, json => $page.rep-ext;
    }

    .post: '/wiki/:page',
        sub ($req, $res, $/) {
            my $txt = $req.json<txt>
                or return self.render: $res,
                        json => { :error<missing text> }, :400status;
            my $page = Page.new: name => ~$<page>, text => $txt;
            if self.pim.save($page) {
              self.render: $res, json => { 'status' => 'ok' };
            } else {
              self.render: $res, :400status, json => { :error<cannot save> } ;
            }
    }

    .get: '/rolodex', {
        my $rolodex = $.pim.rolodex;
        self.render: $^res, 'rolodex' => { :tab<rolodex>, :$rolodex }
    }

    .post: '/search',
        -> $req, $res {
            my $query = $req.json<txt>
                or return self.render: $res, :400status,
                                       json => { :error<missing text> };
            self.render: $res,
                json => [ self.pim.search($query).map:
                          -> $p { %{ label => $p.label, href => $p.href } } ]
    }

    .post: '/rolodex', sub {
         my $json = $^req.json;
         my $id = $json<handle>;
         my $card = $id ?? Card.load($id) !! Card.new(text => $json<txt>);
         $.pim.save($card)
             or return self.render: $^res, :400status, json => { :error<cannot save> };
          self.render: $^res, json => { status => 'ok' }
    }

    .post: '/rolodex/search', sub {
        $^req.json<q>:exists or return self.render: $^res, :400status,
                    json => { :error<bad request> };
        my $q = $^req.json<q>;
        my @matches = $.pim.rolodex.search($q);
        self.render: $^res, json => { results => @matches».rep-ext };
    }

}
