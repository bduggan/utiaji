unit class Utiaji::Response;
use Utiaji::Headers;

our %codes =
    200 => "OK",
    201 => "Created",
    301 => "Moved Permanently",
    302 => "Found",
    303 => "See Other",
    400 => "Bad Request",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    409 => "Conflict",
    413 => "Request Entity Too Large",
    414 => "Request URI Too Long",
    500 => "Internal Server Error",
    501 => "Not Implemented",
;

has $.status is rw;
has $.body is rw;
has Utiaji::Headers $.headers is rw = Utiaji::Headers.new;

method to-string {
    my $str = "HTTP/1.1 ";
    my $code = self.code;
    my $code_str = %codes<$code>;
    my $body = self.body;
    return "HTTP/1.1 $code $str\n\n$body".encode("UTF-8");
}
