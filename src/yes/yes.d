/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	yes: Repeatedly print specified string.

	Written by: chaomodus
*/

import std.stdio;
import std.array;

string output = "y";

void main(string[] args) {
	if (args.length > 1) {
		output = args[1 .. $].join(' ');
	}
	while (true) {
		writeln(output);
	}
}
