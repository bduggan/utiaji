use Uhitaji::App;

unit class Uhitaji::App::React is Uhitaji::App;

has $.template-path = 'templates/react';
has $.static-root = 'static/react';

method BUILD {

    $_ = $.router;

    .get: '/react.js', -> $req,$res {
        self.render: $res, static => 'react.js';
    };

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

