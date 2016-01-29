use Utiaji::App;

class Utiaji is Utiaji::App {
method BUILD {
    self.routes = Utiaji::Routes.new;
    given (self.routes) {

        # Routing table.
        .get('/bob',
            sub ($req,$res) {
                $res.headers<Content-Type> = 'text/plain';
                $res.status = 200;
                $res.close('uncle')
            }
        );

    }
}
}
