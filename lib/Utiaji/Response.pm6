unit class Utiaji::Response;
use Utiaji::Headers;
use Utiaji::Log;

has %.codes =
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

has Int $.status is rw;
has Str $.body is rw = "";
has Utiaji::Headers $.headers is rw = Utiaji::Headers.new;

method prepare-response {
    unless $.headers<content-type> {
        $.headers<content-type> = 'text/plain';
    }
    $.headers<content-length> = $.body.encode('UTF-8').elems;
}

method status-line {
    return join ' ', 'HTTP/1.1', $.status, %.codes{$.status} // '';
}

method to-string {
    self.prepare-response unless $.headers<content-length>.defined;
    $!headers<server> = "Utiaji";
    $!headers<connection> = "close";
    return (
        self.status-line,
        $.headers,
        "",
        $.body
    ).join("\r\n");
}
