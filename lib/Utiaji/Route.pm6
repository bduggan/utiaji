unit class Utiaji::Route;
use Utiaji::Pattern;

has $.name;
has $.verb;
has Regex $.path;
has $.code;
has Utiaji::Pattern $.pattern is rw;

method gist {
    return  ( $.verb // "<no verb>" )
        ~ ": " ~ ( $.pattern // $.path.gist // "<no path>");
}

