use Utiaji::App;
use Utiaji::Log;

class Utiaji::App::Default is Utiaji::App {
    method BUILD {

        self.router.get('/', sub ($req,$res) {
            self.render: $res, text => "Welcome to Utiaji."
        });

        self.router.get('/test', sub ($req,$res) {
            self.render: $res, text => "This is a test of the emergency broadcast system."
        });

        self.router.post: '/echo', sub {
            self.render: $^res, json => $^req.json
        };

        self.router.get('/placeholder/:here', sub ($req,$res, $/) {
            self.render: $res, text => $<here>
        });
    }
}
