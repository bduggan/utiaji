use Utiaji::App;
use Utiaji::Log;
use Utiaji::Request;
use Utiaji::Response;
use Utiaji::Router;
use Utiaji::Model::Pim;
use JSON::Fast;

use OAuth2::Client::Google;
use Utiaji::Cookie;

unit class Utiaji::App::Pim is Utiaji::App;

has $.template-path = 'templates/pim';
has $.pim = Utiaji::Model::Pim.new;

method handle-request(Utiaji::Request $request, Utiaji::Router $router) {
    $request.session<planet> //= 'demo';
    nextsame;
}

method setup {
    my $config = from-json('./client_id.json'.IO.slurp);
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
            cal => { :tab<cal>, :cal($cal) }
    }

    .get: '/cal/range/Δfrom/Δto', -> $/ {
            json => self.pim.cal.load(from => ~$<from>,
                 to => ~$<to>, :!align, :!window).as-data;
    }

    .post: '/cal', {
            my $json = $^req.json or return
                self.render: json => { status => 'error',
                    message => 'no data' };
            my $data = $json<data>
                   or return self.render:
                        json => { error => 'missing data', :400status };
            self.pim.save: Day.construct: $json<data>.kv.map: { $^k => ( txt => $^v ) }
            json => { status => 'ok' };
    }

    .get: '/wiki', { redirect('/wiki/main') }

    .get: '/wiki/:page',
        -> $/, $req {
            my $page = self.pim.wiki.page(~$<page>);
            wiki => { :tab<wiki>, :page($page)}
    }

    .get: '/wiki/:page.json',
        -> $/, $req {
            my $page = self.pim.wiki.page($<page>);
            json => $page.rep-ext;
    }

    .post: '/wiki/:page',
        sub ($/, $req) {
            my $txt = $req.json<txt>
                or return json => { :error<missing text> }, :400status;
            my $page = Page.new: name => ~$<page>, text => $txt;
            if self.pim.save($page) {
              return json => { 'status' => 'ok' };
            } else {
              return :400status, json => { :error<cannot save> } ;
            }
    }

    .post: '/w/:page',
        sub ($match, $req ) {
            my $page = self.pim.wiki.page($match<page>) or return self.render: :400status ;
            my $file = $req.json<file> or return self.render: json => { :error<missing file> }, :400status;
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
        rolodex => { :tab<rolodex>, :$rolodex }
    }

    .post: '/search',
        -> $req {
            my $query = $req.json<txt>
                or return self.render: :400status,
                                       json => { :error<missing text> };
            return json => [ self.pim.search($query).map:
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
             or return :400status, json => { :error<cannot save> };
          return json => { :status<ok>, card => $card.rep-ext }
    }

    .post: '/rolodex/search', sub {
        $^req.json<q>:exists or return self.render: :400status,
                    json => { :error<bad request> };
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
        register => { 'via' => $via };
    }

}
