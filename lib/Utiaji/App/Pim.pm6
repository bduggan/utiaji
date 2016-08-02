use Utiaji::App;
use Utiaji::Log;
use Utiaji::Model::Pim;
use JSON::Fast;

use OAuth2::Client::Google;
use Utiaji::Cookie;

unit class Utiaji::App::Pim is Utiaji::App;

has $.template-path = 'templates/pim';
has $.pim = Utiaji::Model::Pim.new;

method setup {
     my $config = from-json('./client_id.json'.IO.slurp);
     my $oauth = OAuth2::Client::Google.new(
        config => $config,
        redirect-uri => $config<web><redirect_uris>[0],
        scope => "https://www.googleapis.com/auth/calendar.readonly email"
     );
     $_ = self;

    .get: '/login', {
        self.redirect_to: $^res, $oauth.auth-uri
     }

    .get: '/oauth', sub ($req,$res) {
        my $code = $req.query-params<code>;
        my $tokens = $oauth.code-to-token(:$code);
        if (my $token = $tokens<access_token>) {
            my $identity = $oauth.verify-id(:id-token($tokens<id_token>));
            $res.headers<set-cookie> =
                ~ Utiaji::Cookie.new:
                    name => "utiaji",
                    value => "test123",
                    domain => 'localhost',
                    :!secure;
            self.render: $res, text => qq:to/HERE/;
                $identity<email>
                {$tokens.gist}
                {$identity.gist}
                {$req.headers}
                ";
                HERE
        } else {
            self.render: $res, text => $tokens.gist;
        }
     }

    .get: '/', { self.redirect_to: $^res, '/wiki' }

    .get: '/cal', {
            my $cal = self.pim.cal.load(focus => Date.today);
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

    .post: '/w/:page',
        sub ($req, $res, $match) {
            my $page = self.pim.wiki.page($match<page>) or return self.render: :400status ;
            my $file = $req.json<file> or return self.render: $res, json => { :error<missing file> }, :400status;
            if $file ~~ rx{ ^ .+ "/" $<name>=(<-[/]>+) $ } {
                $file = ~$<name>;
            }

            if $page.add-file($file) {
                return self.render: $res, json => { status => "ok" };
            } else {
                return self.render: :504status, json => "error";
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
         my $card;
         if ($id) {
            $card = $.pim.card($id);
            $card.set-text( $json<txt> );
         } else {
            $card = Card.new(text => $json<txt>);
         }
         $.pim.save($card)
             or return self.render: $^res, :400status, json => { :error<cannot save> };
          self.render: $^res, json => { :status<ok>, card => $card.rep-ext }
    }

    .post: '/rolodex/search', sub {
        $^req.json<q>:exists or return self.render: $^res, :400status,
                    json => { :error<bad request> };
        my $q = $^req.json<q>;
        my @matches = $.pim.rolodex.search($q);
        self.render: $^res, json => { results => @matches».rep-ext };
    }

    .get: '/feed.json', sub {
        self.render: $^res, json => { latest => $.pim.latest }
    }

    .get: '/feed', sub {
        self.render: $^res, 'feed' => { latest => $.pim.latest }
    }

}
