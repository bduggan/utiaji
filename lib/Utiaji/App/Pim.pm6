use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;

method BUILD {
    my $r = self.router;

    $r.get: '/',
    sub ($req, $res) {
        $res.headers{"Location"} = "/cal";
        self.render: :302status;
    };

    $r.get: '/cal',
    sub ($req,$res) {
        self.render: $res,
            template => 'pim/cal',
    };

    $r.get: '/wiki',
    sub ($req,$res) {
        self.render: $res,
            template => 'pim/wiki',
    };

}
