% TEE(1dunex) Version 1.0 | DUNEX Core

NAME
====

**tee** - Copy stdin to stdout.

SYNOPSIS
========

| **tee** [_FLAGS_] [_FILES_...]

DESCRIPTION
===========

Copies stdin to stdout, and optionally other files, according to the set flags.

FLAGS
======

 **-a**, **\--append**  Append to rather than overwriting the specified file(s).

 **-b**, **\--full-buffer**  Fully buffer the input stream. The program must exit by encountering `EOF` to write to any file(s) besides stdout.

 **-i**, **\--ignore-interrupt**  Ignore the SIGINT interrupt signal.

 **-l**, **\--line-buffer**  Buffer the input stream until a newline is encountered.

 **-n**, **\--no-buffer**  (default) Do not buffer the input stream.

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
