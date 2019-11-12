/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	uname: Print information about the operating system.

	Written by: chaomodus
*/

import std.stdio;
import std.string;
import std.algorithm : canFind;
import core.stdc.errno;
import core.sys.posix.sys.utsname;
import core.stdc.stdio : perror;

int main(string[] args) {
	utsname info;
	int result = core.sys.posix.sys.utsname.uname(&info);

	if (result == 0) {
		// Handle cases for no arguments and for -a argument.
		if (args.length == 1)
			args = ["", "-s"];
		if (args.canFind("-a"))
			args = ["", "-s", "-n", "-r", "-v", "-m"];

		foreach (idx, arg; args[1 .. $]) {
			switch (arg) {

			case "-o", "-s":
				stdout.write(info.sysname);
				break;

			case "-n":
				stdout.write(info.nodename);
				break;

			case "-r":
				stdout.write(info.release);
				break;

			case "-v":
				stdout.write(info.version_);
				break;

			case "-m":
				stdout.write(info.machine);
				break;

			default:
				stdout.writeln("unknown argument: ", arg);
				return 1;

			}

			if (idx != args.length - 2) {
				stdout.write(" ");
			}
		}
	} else {
		perror(null);
		return 1;
	}
	stdout.write("\n");
	return 0;
}
