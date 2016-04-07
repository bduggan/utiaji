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

