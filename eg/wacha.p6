#!/usr/bin/env perl6
use Wacha;

/ 'hello world';

/hello/:name -> $/ { "hello, $<name>" }

go;

