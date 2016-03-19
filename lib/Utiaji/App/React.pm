use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::React is Utiaji::App;

method BUILD {

    self.routes.get('/react.js', sub ($req,$res) {
        self.render: $res, static => 'react/react.js';
    });

    self.routes.get('/cal', sub ($req,$res) {
        self.render: $res,
            template => 'react/cal',
    });

    self.routes.get('/today', sub ($req,$res) {
        self.render: $res,
           json => { "events" => [ "eat", "drink", "be merry"] }
    });

    self.routes.get('/tomorrow', sub ($req,$res) {
        self.render: $res,
           json => { "events" => [ "we die" ] }
    });

}
