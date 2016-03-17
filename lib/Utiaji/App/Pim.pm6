use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;

method BUILD {

    self.routes.get('/utiaji', sub ($req,$res) {
        self.render: $res, static => 'pim/utiaji.js';
    });

    self.routes.get('/cal', sub ($req,$res) {
        self.render: $res,
            template => 'pim/cal',
    });

    self.routes.get('/wiki', sub ($req,$res) {
        self.render: $res,
            template => 'pim/wiki',
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
