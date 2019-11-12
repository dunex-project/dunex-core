/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	false / true / return: Exit with true, false or specified value.

	Author(s): chaomodus
*/

import std.conv;
import std.algorithm;

int main(string[] args) {
	int retval = 0;
	if (args[0].endsWith("false")) {
		retval = 1;
	}
	if (args.length >= 2) {
		retval = parse!int(args[1]);
	}
	return retval;
}
