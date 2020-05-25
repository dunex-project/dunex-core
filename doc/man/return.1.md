% RETURN(1dunex) Version 1.0 | DUNEX Core

NAME
====

**return** - return true, false, or a specified numeric value.

SYNOPSIS
========

| **return** [_VALUE_]

DESCRIPTION
===========

Returns true (0) if named 'true', false (1) if named 'false', or a numeric value
passed as a commandline argument if named anything else. Note that when not named
'false' and when called with no arguments, the return value will be zero/true.

NOTES
=====

Under at least bash, return values are bytes. This means that any value over 255
will roll over. Thus the actual value returned will be _VALUE_ % 255.

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
