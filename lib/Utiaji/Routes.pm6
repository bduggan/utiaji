class Utiaji::Route {
    has $.name is rw;
    has $.verb is rw;
    has $.path is rw;
    has $.code is rw;
}

class Utiaji::Routes {
    has Array $.routes is rw = [];

    method lookup(:$path!,:$verb!) {

        my @matches;
        my $captures;
        for self.routes.flat -> $route {
            next unless $verb eq $route.verb;
            next unless $path ~~ $route.path;
            push @matches, $route;
            $captures = $/;
        }
        if (@matches==1) {
            return ( @matches[0], $captures );
        }
        if (@matches > 1) {
            warn "multiple matches for $verb $path\n";
            return;
        }
        return;
    }

    method get($path, $cb) {
        my $r = Utiaji::Route.new(
                verb => 'GET',
                path => $path,
                code => $cb
        );
        self.routes.push($r);
    }

    method post($path, $cb) {
        my $r = Utiaji::Route.new(
                verb => 'POST',
                path => $path,
                code => $cb
        );
        self.routes.push($r);
    }

}

