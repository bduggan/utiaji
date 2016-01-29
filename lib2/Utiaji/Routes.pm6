class Utiaji::Route {
    has $.name is rw;
    has $.verb is rw;
    has $.path is rw;
    has $.code is rw;
}

class Utiaji::Routes {
    has Array $.routes is rw = [];

    method lookup(:$path!,:$verb!) {
        my @matches = self.routes.grep( {
            .path eq $path && .verb eq $verb }
        );
        if (@matches==1) {
            return @matches[0];
        }
        return;
    }

    method get($path, $cb) {
        my $r = Utiaji::Route.new(verb => 'GET', path => $path, code => $cb);
        self.routes.push($r);
    }
}

