use Utiaji::App;
use Utiaji::DB;
use Utiaji::Log;

unit class Utiaji::App::Pim is Utiaji::App;

has $.db = Utiaji::DB.new;
has $.template-path = 'templates/pim';

method BUILD {
    my $r = self.router;

    $r.get: '/',
    sub ($req, $res) {
        $res.headers{"Location"} = "/cal";
        $res.status = 302;
    };

    $r.get: '/cal',
    sub ($req,$res) {
        self.render: $res,
            template => 'cal',
            template_params => { tab => "cal", today => "monday" }
    };

    $r.get: '/wiki',
    sub ($req,$res) {
        self.render: $res,
            template => 'wiki',
            template_params => { tab => "wiki" }
    };

    $r.get: '/people',
    sub ($req,$res) {
        self.render: $res,
            template => 'wiki',
            template_params => { tab => "people" }
    };


}
