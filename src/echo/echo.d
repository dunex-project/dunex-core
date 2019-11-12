/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	echo: Print arguments to stdout.
	Author(s): chaomodus
 */

import std.stdio;

bool noend = false;

int main(string[] arg) {
	string[] words = arg[1 .. $];
	if (words.length > 0) {
		if (words[0] == "-n") {
			noend = true;
			words = words[1 .. $];
		}
	}
	foreach (i, s; words) {
		stdout.write(s);
		if (i + 1 != words.length) {
			stdout.write(" ");
		}
	}
	if (!noend) {
		stdout.write("\n");
	}
	return 0;
}
