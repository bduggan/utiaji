class Utiaji::Headers {
    has %.fields is rw;
    has $.content-type is rw;

    method host {
        return %.fields<Host>;
    }
}


