use Uhitaji::App;
use Uhitaji::Log;

class Uhitaji::App::Default is Uhitaji::App {
    method BUILD {

        self.router.get('/', sub ($req,$res) {
            self.render: $res, text => "Welcome to Uhitaji."
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
