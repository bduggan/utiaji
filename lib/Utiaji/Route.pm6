unit class Utiaji::Route;

has $.name;
has $.verb;
has Regex $.path;
has $.code;
has $.matcher is rw;

method gist {
    return  ( self.verb // "<no verb>" )
        ~ ": " ~ ( self.path.gist // "<no path>");
}

#sub get(Pair $pair) is export {
#    my ($path, $cb) = $pair.kv;
#    say "get got $path { $cb.perl } ";
#    $path = rx{^$path$} unless $path.isa('Regex');
#    return Utiaji::Route.new(verb => 'GET', path => $path, code => $cb);
#}

#multi infix:<▶>(Pair $req, Code $cb) is export is tighter(&infix:<,>) is looser(&infix:<=\>>) {
#    my ($verb,$path) = $req.kv;
#    $path = rx{^$path$} unless $path.isa('Regex');
#    return Utiaji::Route.new(verb => $verb.uc, path => $path, code => $cb);
#}


