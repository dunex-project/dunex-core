/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	tee: Copy stdin to stdout (unbuffered), and, optionally one or more output files.
	Author(s): chaomodus
*/

import std.exception;
import std.stdio;
import std.getopt;
import std.file;
import std.process;
import core.sys.posix.signal;

string output;
bool ignore_int = false;
bool append = false;
bool interrupted = false;

extern (C) void sigint_handler(int signal) nothrow @nogc @system {
	if (!ignore_int) {
		interrupted = true;
	}
}

int main(string[] args) {
	auto helpInformation = getopt(args, std.getopt.config.passThrough,
		"i|ignore-int", "Specify the octal mode of the directory to create.", &ignore_int, 
		"a|append", "Create the parents of the target directory (if necessary).", &append
	);

	if (helpInformation.helpWanted) {
		defaultGetoptPrinter(
			"Copy stdin to stdout, and perhaps some other files.",
			helpInformation.options
		);
		return 1;
	}

	signal(SIGINT, &sigint_handler);

	char[1] outbuff;
	char[] inp;
	File[] outf = [stdout];
	if (args.length > 1) {
		foreach (fname; args[1 .. $]) {
			outf ~= [File(fname, append ? "a" : "w")];
		}
	}
	while (!interrupted) {
		try {
			inp = stdin.rawRead(outbuff);
		} catch (ErrnoException e) {
			writeln("error occured during reading: ", e.msg);
		}
		if (inp.length > 0) {
			foreach (f; outf) {
				f.rawWrite(inp);
			}
		} else if (stdin.eof) {
			interrupted = true;
		}
	}

	foreach (f; outf) {
		f.close();
	}
	return 0;
}
