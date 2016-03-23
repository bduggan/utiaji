use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;

method BUILD {

    self.router.get('/cal', sub ($req,$res) {
        self.render: $res,
            template => 'pim/cal',
    });

    self.router.get('/wiki', sub ($req,$res) {
        self.render: $res,
            template => 'pim/wiki',
    });

}
