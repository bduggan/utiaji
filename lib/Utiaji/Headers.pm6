class Utiaji::Headers {
    has %.fields is rw;
    has Str $.content-type is rw;

    method host {
        return %.fields<Host>;
    }
}


