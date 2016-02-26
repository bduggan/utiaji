unit class Utiaji::Response;
use Utiaji::Headers;

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

has $.status is rw;
has $.status-line is rw;
has $.body is rw;
has Utiaji::Headers $.headers is rw = Utiaji::Headers.new;

method prepare-response {
    unless $.headers.content-type {
        $.headers.content-type = 'text/plain';
    }
    $.headers.content-length = $.body.chars;
}

method status-line {
    return join ' ', 'HTTP/1.1', $.status, %.codes{$.status} // '';
}

method to-string {
    self.prepare-response unless $.headers.content-length.defined;
    my @lines = (
        self.status-line,
        "Server: Utiaji";
        "Content-Type: { $.headers.content-type }";
        "Content-Length { $.headers.content-length }";
        "Connection: Close";
    );
    my $str = @lines.join("\r\n");
    $str ~= "\r\n\r\n$.body";
    return $str;
}
