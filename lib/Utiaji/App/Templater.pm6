use Utiaji::App;
use Utiaji::Log;
use Utiaji::Template;

class Utiaji::App::Templater is Utiaji::App {
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
