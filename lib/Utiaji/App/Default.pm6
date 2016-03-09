use Utiaji::App;
use Utiaji::Log;

class Utiaji::App::Default is Utiaji::App {
    method BUILD {

        self.routes.get('/', sub ($req,$res) {
            self.render: $res, text => "Welcome to Utiaji."
        });

        self.routes.get('/test', sub ($req,$res) {
            self.render: $res, text => "This is a test of the emergency broadcast system."
        });

        self.routes.post('/echo', sub ($req,$res) {
            self.render: $res, json => $req.json
        });

        self.routes.get('/placeholder/:here', sub ($req,$res, $/) {
            self.render: $res, text => $<here>
        });
    }
}
