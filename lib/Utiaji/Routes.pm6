
unit class Utiaji::Routes;
use Utiaji::Log;
use Utiaji::Matcher;
use Utiaji::Route;

has Utiaji::Route @.routes is rw = ();

method lookup(:$verb!,:$path!) {
    trace "Lookup $verb $path";

    my @matches;
    my Match $captures;
    for self.routes.flat -> $route {
        trace "Comparing with { $route.gist } ";
        next unless $verb eq $route.verb;
        if ($route.matcher and $route.matcher.match($path)) {
            $captures = $route.matcher.captures;
            push @matches, $route;
            next;
        }
        next unless $path ~~ $route.path;
        push @matches, $route;
        $captures = $/.clone;
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

multi method get(Str $pattern, $cb) {
    my $r = Utiaji::Route.new(
            verb => 'GET',
            path => rx{^$pattern$},
            matcher => Utiaji::Matcher.new(pattern => $pattern),
            code => $cb
    );
    self.routes.push($r);
}

multi method get(Regex $path, $cb) {
    my $r = Utiaji::Route.new(
            verb => 'GET',
            path => $path,
            code => $cb
    );
    self.routes.push($r);
}

multi method post(Str $pattern, $cb) {
    my $r = Utiaji::Route.new(
            verb => 'POST',
            path => rx{^$pattern$},
            matcher => Utiaji::Matcher.new(pattern => $pattern),
            code => $cb
    );
    self.routes.push($r);
}


multi method post(Regex $path, $cb) {
    my $r = Utiaji::Route.new(
            verb => 'POST',
            path => $path,
            code => $cb
    );
    self.routes.push($r);
}

