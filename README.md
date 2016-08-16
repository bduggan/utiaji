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
psql utiaji -f schema.sql
./install.sh

Run
===
PGDATABASE=utiaji ./bin/utiaji

About
=====
This is a web-application written in Perl 6. It uses the
following architecture:

A server has an app which handling and rendering.
An app has a router.

Handling does dispatching with the app's router.

Dispatching invokes a callback which generates response.
The callback can alternatively generate arguments for
the renderer which will generate the response.

Apps may inherit from the above app and override the
various roles or wrap them.



