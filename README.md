Utiaji -- A Personal Information Organizer
=======
* Travis: [![Build Status](https://travis-ci.org/bduggan/utiaji.svg?branch=master)](https://travis-ci.org/bduggan/utiaji)
* Circle CI: [![CircleCI Status](https://circleci.com/gh/bduggan/utiaji/tree/master.svg?style=svg)](https://circleci.com/gh/bduggan/utiaji/tree/master)

Description
===========
Utiaji is personal information organizer composed of a calender, wiki, and address book.
It is written in Perl 6.

Install
=======
* Install [Perl 6](https://perl6.org/downloads/) and [zef](https://github.com/ugexe/zef).
```
createdb utiaji
psql utiaji -f schema.sql
zef install --deps-only .
```

Run
===
Utiaji uses nginx for static content.  A configuration
and start script are included.
```
./bin/start-nginx
PGDATABASE=utiaji ./bin/utiaji
```

Demo
===
A live installation is at <http://utiaji.org>.

THANKS
===
* to Ryan Hinkel for all the React help.

