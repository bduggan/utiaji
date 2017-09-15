use Utiaji::Handler;
use Utiaji::Router;
use Utiaji::Log;
use Utiaji::Renderer;

unit class Utiaji::App
    does Utiaji::Handler
    does Utiaji::Renderer;

has $.root is rw = $?FILE.IO.parent.parent.dirname;
has $.router handles <get post put> = Utiaji::Router.new;

method BUILDALL(|) {
    callsame;
    self.setup();
    self;
}

method setup {}

