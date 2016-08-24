
use Utiaji::App;
use Utiaji::Response;
use Utiaji::Error;

unit class Utiaji::App::Default is Utiaji::App;

method setup {

  self.get: '/', -> {
      :text<Welcome to Utiaji.>
  }

  self.get: '/hello', -> {
      :text<is it me>
  }

  self.get: "/you-are", -> {
      :text<looking for>
  }

  self.get: "/greet/:name", -> $/ {
      :text«hi, $<name>»
  }

  self.get: "/hola/:name", -> $/, $req {
      text => ( "Hi, $<name> from " ~ $req.param('from') )
  }

  self.get: "/fail", {
      fail bad-request;
  }

  self.get: "/look", -> {
      redirect('/here')
  }

  self.get: "/count", -> $req {
    $req.session<sheep>+=1;
    self.render( template => "count", sheep => $req.session<sheep> );
  }

  self.get: "/here", -> {
      json => { answer => 42 }
  }

  self.post: '/echo', -> $req {
     json => $req.json
  }

}
