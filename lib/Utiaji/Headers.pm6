class Utiaji::Headers {
    has %.fields is rw;
    has Str $.content-type is rw;
    has Int $.content-length is rw;

    method host {
        return %.fields<Host>;
    }

    method normalize {
        for %.fields.kv -> $k, $v {
            if fc($k) eq fc('content-length') {
                $.content-length = 0+$v;
            }
        }
    }
}


