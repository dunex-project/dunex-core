% SEQ(1dunex) Version 1.0 | DUNEX Core

NAME
====

**seq** - output a sequence of numbers

SYNOPSIS
========

| **seq** \[_OPTIONS_ || _FLAGS_] [_first_ [_incr_]] last

DESCRIPTION
===========

Prints numbers in the range beginning with first and ending with last, advancing each step by incr. First defaults to 0 and incr defaults to 1.

If first has a higher value than last, the sequence will count down from last to first.

OPTIONS
=======

**-f**, **\--format=**  A printf(3)-style format for the printed values.

**-s**, **\--separator=**  A string to separate each value. If specified without also specifying **-t**, this is also the terminator. If neither is specified, defaults to a newline.

**-t**, **\--terminal=**  A string to add at the end of the sequence. Defaults to a newline.

FLAGS
=====

**-w**, **\--fixed-width**  Pad each value to the maximum width of its type.

AUTHORS
=======

chaomodus

INTEGRATION
===========

Part of the DUNEX System

dunex-core Version 1.0

SEE ALSO
========

**dunex-core(7dunex)** **dunex(7dunex)**
