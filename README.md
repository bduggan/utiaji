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
createdb utiaji
psql utiaji -c 'create table kv(k varchar not null primary key, v jsonb)'
./install.sh

Run
===
PGDATABASE=utiaji ./bin/utiaji

