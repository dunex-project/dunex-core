% YES(1dunex) Version 1.0 | DUNEX Core

NAME
====

**yes** - repeatedly print the specified string or 'y'

SYNOPSIS
========

| **yes** \[**-n**|**\--no-newline**] [_STRING_]...

DESCRIPTION
===========

Repeatedly prints the string specified on the command line. If no string is provided, prints 'y' instead.

This implementation passes through properly escaped command characters; e.g.
'\\t' will be a tab or '\\uHHHH' will be the UTF-8 character represented by that
hexadecimal code.

FLAGS
=====

**-n**, **\--no-newline**  Do not add a newline after the printed string.

AUTHORS
=======

chaomodus
Marie-Joseph

INTEGRATION
===========

Part of the DUNEX System

dunex-core Version 1.0

SEE ALSO
========

**dunex-core(7dunex)** **dunex(7dunex)**
