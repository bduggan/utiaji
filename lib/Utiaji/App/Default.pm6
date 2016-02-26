use Utiaji::App;

class Utiaji::App::Default is Utiaji::App {
    method BUILD {
        self.routes.get('/', sub ($req,$res) {
            self.render: $res, text => "welcome to utiaji"
        })
    }
}
