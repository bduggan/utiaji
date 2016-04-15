use Uhitaji::App;
use Uhitaji::Log;
use Uhitaji::Template;

class Uhitaji::App::Templater is Uhitaji::App {
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
