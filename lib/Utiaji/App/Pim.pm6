use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;

method BUILD {
    self.routes.get('/cal', sub ($req,$res) {
        self.render: $res,
            template => 'pim/cal',
    });
}
