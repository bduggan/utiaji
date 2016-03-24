use Utiaji::App;
use Utiaji::Log;

unit class Utiaji is Utiaji::App;

method BUILD {
    self.router.get('/', sub ($req,$res) {
        self.render: $res, static => 'main.html';
    });
}
