use Hamna::App;
use Hamna::Log;
use Hamna::Template;

class Hamna::App::Templater is Hamna::App {
    has $.template-path = 'templates/templater';
    method BUILD {
        self.router.get('/hello', sub ($req, $res) {
            self.render: $res, template => "hello"
        });
        self.router.get('/hello/:person', sub ($req, $res, $/) {
            self.render: $res,
                template => "hello/person",
                template_params => { name => $<person> }
        });
        self.router.get('/headfoot', sub ($req, $res) {
            self.render: $res, template => "headfoot"
        });

    }
}
