use Utiaji::App;
use Utiaji::Log;
use Utiaji::Template;

class Utiaji::App::Templater is Utiaji::App {
    has $.template-path = 'templates/templater';
    method BUILD {
        self.router.get('/hello', sub ($req) {
            template => "hello"
        });
        self.router.get('/hello/:person', sub ($/, $req) {
            { template => "hello/person",
              name => $<person> }
        });
        self.router.get('/headfoot', sub ($req) {
            template => "headfoot"
        });

    }
}
