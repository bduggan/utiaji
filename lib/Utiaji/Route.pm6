unit class Utiaji::Route;
use Utiaji::Pattern;

has $.name;
has $.verb;
has Regex $.path;
has $.code;
has Utiaji::Pattern $.matcher is rw;

method gist {
    return  ( self.verb // "<no verb>" )
        ~ ": " ~ ( self.path.gist // "<no path>");
}

