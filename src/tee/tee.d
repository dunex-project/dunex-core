/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	tee: Copy stdin to stdout (unbuffered), and, optionally one or more output files.
	Author(s): chaomodus

	TODO:
	* Does not properly write to files, let alone append to them, since port
*/
module app;

import common.cmd;

import core.sys.posix.signal;
import std.exception;
import std.stdio;
import std.getopt;
import std.file;
import std.process;

enum APP_NAME = "tee";
enum APP_DESC = "Copy stdin to stdout, and perhaps some other files.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("a", "append", "Append to rather than overwriting output file(s).").name("append").optional);
		app.add(new Flag("i", "ignore-interrupt", "Ignore the SIGINT signal.").name("ignoreInt").optional);
		app.add(new Argument("files", "File(s) where output is written.").name("files").optional.repeating);
	},
	(ProgramArgs args) {
		try {
			if (args.flag("ignoreInt"))
				signal(SIGINT, SIG_IGN);

			char[1] outbuff;
			char[] inp;
			File[] outf = [stdout];
			writeln(args.args("files"));
			if (args.arg("files").length > 1) {
				foreach (fname; args.args("files")) {
					outf ~= [File(fname, args.flag("append") ? "a" : "w")];
				}
			}
			while (true) {
				try {
					inp = stdin.rawRead(outbuff);
				} catch (ErrnoException e) {
					writeln(APP_NAME, ": error occured during reading: ", e.msg);
				}
				if (inp.length > 0) {
					foreach (f; outf) {
						f.rawWrite(inp);
					}
				} else if (stdin.eof) {
					break;
				}
			}

			foreach (f; outf) {
				f.close();
			}
			return 0;
		} catch (Exception ex) {
			stderr.writeln(APP_NAME, ": ", ex.msg);
			return 1;
		}
	});
}
