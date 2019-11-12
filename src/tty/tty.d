/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	tty: Print the name of the tty running under.

	Written by: chaomodus
*/

import std.stdio;
import std.string;
import std.getopt;

bool silent = false;

extern (C) char* ttyname(int fd);

int main(string[] args) {
	auto helpInformation = getopt(args, std.getopt.config.passThrough,
		"s|silent", "Do not print any output.", &silent
	);

	if (helpInformation.helpWanted) {
		defaultGetoptPrinter("Print the name of the current tty.", helpInformation.options);
		return 1;
	}

	char* tty = ttyname(stdout.fileno);

	if (!tty) {
		return 2;
	}
	if (!silent) {
		writeln(fromStringz(tty));
	}
	return 0;
}
