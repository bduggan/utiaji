use Utiaji::App;
use Utiaji::Log;
use Utiaji::Request;
use Utiaji::Response;
use Utiaji::Router;
use Utiaji::Model::Pim;
use Utiaji::Error;
use JSON::Fast;

use OAuth2::Client::Google;
use Utiaji::Cookie;

unit class Utiaji::App::Pim is Utiaji::App;

has $.template-path = 'templates/pim';
has $.pim = Utiaji::Model::Pim.new;
has $.oauth-config-file='./client_id.json';

method handle-request(Utiaji::Request $request, Utiaji::Router $router) {
    $request.session<planet> //= 'demo';
    nextsame;
}

method setup {
    my $config = from-json(self.oauth-config-file.IO.slurp);
    my $oauth = OAuth2::Client::Google.new(
       config => $config,
       redirect-uri => $config<web><redirect_uris>[0],
       scope => "https://www.googleapis.com/auth/calendar.readonly email",
       prompt => "none",
    );
    $_ = self;

    .get: '/login', {
       redirect: $oauth.auth-uri
    }

    .get: '/logout', {
       $^req.session.expiration = -1;
       redirect: '/'
    }

    .get: '/oauth', sub ($req) {
        my $code = $req.query-params<code>;
        my $tokens = $oauth.code-to-token(:$code);
        if (my $token = $tokens<access_token>) {
            my $identity = $oauth.verify-id(:id-token($tokens<id_token>));
            $req.session<user> = $identity<email>;
            redirect('/');
        } else {
            return text => "auth failed";
        }
     }

    .get: '/', { redirect('/wiki') }

    .get: '/cal', {
            my $cal = self.pim.cal.load(focus => Date.today);
            self.render: template => 'cal', :tab<cal>, :cal($cal)
    }

    .get: '/cal/Δday',
        -> $/, $req {
            my $cal = self.pim.cal.load(focus => ~$<day>);
            self.render: template => 'cali', :tab<cal>, :cal($cal)
    }

    .get: '/cal/range/Δfrom/Δto', -> $/ {
            json => self.pim.cal.load(from => ~$<from>,
                 to => ~$<to>, :!align, :!window).as-data;
    }

    .post: '/cal', {
            my $json = $^req.json or fail bad-request('no data',:json);
            my $data = $json<data> or fail bad-request('missing data',:json);
            self.pim.save: Day.construct: $json<data>.kv.map: { $^k => ( txt => $^v ) }
            json => { status => 'ok' };
    }

    .get: '/wiki', { redirect('/wiki/main') }

    .get: '/wiki/:page',
        -> $/, $req {
            my $page = self.pim.wiki.page(~$<page>);
            self.render: template => 'wiki', :tab<wiki>, :page($page)
    }

    .get: '/wiki/:page.json',
        -> $/, $req {
            my $page = self.pim.wiki.page($<page>);
            json => $page.rep-ext;
    }

    .post: '/wiki/:page',
        sub ($/, $req) {
            my $txt = $req.json<txt> or fail bad-request('missing text');
            my $page = Page.new: name => ~$<page>, text => $txt;
            if self.pim.save($page) {
              return json => { 'status' => 'ok' };
            } else {
              fail bad-request('cannot save',:json);
            }
    }

    .post: '/w/:page',
        sub ($match, $req ) {
            my $page = self.pim.wiki.page($match<page>) or fail bad-request;
            my $file = $req.json<file> or fail bad-request('missing file', :json);
            if $file ~~ rx{ ^ .+ "/" $<name>=(<-[/]>+) $ } {
                $file = ~$<name>;
            }

            if $page.add-file($file) {
                return json => { status => "ok" };
            } else {
                return :504status, json => "error";
            }
        }

    .get: '/rolodex', {
        my $rolodex = $.pim.rolodex;
        self.render: template => "rolodex", :tab<rolodex>, :$rolodex;
    }

    .post: '/search', -> $req {
            my $query = $req.json<txt> or fail bad-request('missing text', :json);
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
         $.pim.save($card) or fail bad-request('cannot save',:json);
         return json => { :status<ok>, card => $card.rep-ext }
    }

    .post: '/rolodex/search', sub {
        $^req.json<q>:exists or fail bad-request(:json);
        my $q = $^req.json<q>;
        my @matches = $.pim.rolodex.search($q);
        json => { results => @matches».rep-ext };
    }

    .get: '/planets', sub {
        :template<planets>;
    }

    .post: '/planet/add', sub {
        json => { test => 'todo' };
    }

    .get: "/register", sub {
        debug $^req.query-params<via>;
        my $via = $^req.query-params<via>;
        self.render: template => 'register', 'via' => $via;
    }

}
