class Utiaji::Headers {
    has %.fields is rw;
    has Str $.content-type is rw;
    has Int $.content-length is rw;

    method host {
        return %.fields<Host>;
    }
}


