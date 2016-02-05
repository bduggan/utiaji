use Utiaji::Log;

class Utiaji::Route {
    has $.name;
    has $.verb;
    has Regex $.path;
    has $.code;
    method brief {
        return  ( self.verb // "<no verb>" )
              ~ ": "
              ~ ( self.path.gist // "<no path>");
    }
}

class Utiaji::Routes {
    has Array $.routes is rw = [];

    method lookup(:$verb!,:$path!) {
        trace "# Utiaji::Routes, lookup $verb $path";

        my @matches;
        my $captures;
        for self.routes.flat -> $route {
            next unless $verb eq $route.verb;
            next unless $path ~~ $route.path;
            trace "# Utiaji::Routes, found { $route.verb } { $route.path.perl }";
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

    method get(Regex $path, $cb) {
        my $r = Utiaji::Route.new(
                verb => 'GET',
                path => $path,
                code => $cb
        );
        self.routes.push($r);
    }

    method post(Regex $path, $cb) {
        my $r = Utiaji::Route.new(
                verb => 'POST',
                path => $path,
                code => $cb
        );
        self.routes.push($r);
    }

}

