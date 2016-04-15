use lib 'lib';
use Test;
use Uhitaji::Test;

class Uhitaji::App::React is Uhitaji::App {
    method BUILD {
        $.root = $?FILE.IO.dirname.child('react');

        $.routes.get('/react.js', sub ($req,$res) {
            self.render: $res, static => 'react.js';
        });

        $.routes.get('/cal', sub ($req,$res) {
            self.render: $res,
                template => 'react/cal',
        });

        $.routes.get('/today', sub ($req,$res) {
            self.render: $res,
               json => { "events" => [ "eat", "drink", "be merry"] }
        });

        $.routes.get('/tomorrow', sub ($req,$res) {
            self.render: $res,
               json => { "events" => [ "we die" ] }
        });

    }

}


my $t = Uhitaji::Test.new.start( Uhitaji::App::React.new );

$t.get-ok('/cal').status-is(200);

$t.get-ok('/today').status-is(200)
  .json-is({events => [«eat drink "be merry"»]});

$t.get-ok('/tomorrow').status-is(200)
  .json-is({events => ["we die"]});

$t.get-ok('/react.js').status-is(200);

# To test in a browser:
# prompt 'press return to stop';

$t.stop;

done-testing;

