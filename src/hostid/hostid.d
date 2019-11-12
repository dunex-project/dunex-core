/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	hostid: Print the 32 bit host id in hex.

	Author(s): chaomodus
 */

import std.stdio;
import std.format;

extern (C) ulong gethostid();

void main() {
	writeln(format("%08x", gethostid()));
}
