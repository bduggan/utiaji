class Utiaji::Error is Exception {
    has Int $.status = 500;
    has Str $.text = 'something went wrong';
    has Bool $.json = False;
    method message {
        return $.text;
    }
}

# constructors
sub internal-error ($text = "something is wrong",:$json = False) is export {
    return Utiaji::Error.new(:$text,:$json);
}

sub bad-request ($text = "bad request",:$json = False,:$status=400) is export {
    return Utiaji::Error.new(:$text,:$status,:$json);
}

sub forbidden ($text = "forbidden",:$json = False) is export {
    return Utiaji::Error.new(:$text,:403status,:$json);
}
