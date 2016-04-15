use Hamna::App;
use Hamna::Log;

class Hamna::App::Default is Hamna::App {
    method BUILD {

        self.router.get('/', sub ($req,$res) {
            self.render: $res, text => "Welcome to Hamna."
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
