% TTY(1dunex) Version 1.0 | DUNEX Core

NAME
====

**tty** - print the name of the standard input tty

SYNOPSIS
========

| **tty** [_-s_ | _--silent_]

DESCRIPTION
===========

Prints the name of the standard input tty and returns 0. If stdin is not a tty,
returns 1. If an error occurs, returns >1.

AUTHOR
======

chaomodus

INTEGRATION
===========

Part of the DUNEX System

dunex-core Version 1.0

SEE ALSO
========

**dunex-core(7dunex)** **dunex(7dunex)**
