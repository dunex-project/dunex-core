/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	basename: print directory part of the specified path
	Author(s): chaomodus
*/

import std.path : dirName;
import std.stdio;

int main(string[] args) {
	if (args.length < 2) {
		writeln(args[0], ": specify at least one path");
		return 1;
	}
	foreach (path; args[1 .. $]) {
		writeln(dirName(path));
	}
	return 0;
}
