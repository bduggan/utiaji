class Utiaji::Error is Exception {
    has Int $.status = 500;
    has Str $.text = 'something went wrong';
    method message {
        return $.text;
    }
}

sub internal-error ($text = "something is wrong") is export {
    return Utiaji::Error.new(:$text);
}

sub bad-request ($text = "bad request") is export {
    return Utiaji::Error.new(:$text,:400status);
}

sub forbidden ($text = "forbidden") is export {
    return Utiaji::Error.new(:$text,:403status);
}
