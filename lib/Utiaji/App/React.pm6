use Utiaji::App;

unit class Utiaji::App::React is Utiaji::App;

has $.template-path = 'templates/react';

method BUILD {

    $_ = $.router;

    $.router.get('/cal', sub ($req,$res) {
        self.render: $res,
            template => 'cal',
    });

    $.router.get('/today', sub ($req,$res) {
        self.render: $res,
           json => { "events" => [ "eat", "drink", "be merry"] }
    });

    $.router.get('/tomorrow', sub ($req,$res) {
        self.render: $res,
           json => { "events" => [ "we die" ] }
    });

}

