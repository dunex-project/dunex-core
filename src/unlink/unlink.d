/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	unlink: call unlink function on specified file.
	Author(s): chaomodus
*/

import std.stdio;
import std.string;
import core.stdc.stdio : perror;

extern (C) int unlink(const char* path);

int main(string[] args) {
	if (args.length != 2) {
		writeln("Incorrect number of arguments: specify one filename.");
		return 1;
	}

	int result = unlink(toStringz(args[1]));
	if (result != 0) {
		perror(toStringz(format("%s - %s", args[0], args[1])));
		return 1;
	}

	return 0;
}
