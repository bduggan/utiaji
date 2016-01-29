use Utiaji::App;

class Utiaji is Utiaji::App {
method BUILD {
    self.routes = Utiaji::Routes.new;
    given (self.routes) {

        # Routing table.
        .get('/',
            sub ($req,$res) {
                $res.headers<Content-Type> = 'text/plain';
                $res.status = 200;
                $res.close('Welcome to Utiaji.')
            }
        );

         my regex piece { <-[ / ]>+ };
        .get(rx{^ \/get\/<key=piece> $},
            sub ($req,$res, $m) {
                $res.headers<Content-Type> = 'text/plain';
                $res.status = 200;
                $res.close("We got $m<key>\n");
            }
        );

    }
}
}
