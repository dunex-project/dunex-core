/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by: Marie-Joseph and moon child

	Bugs:

	Todo:
	* implement all flags' functionality
	* manpage

*/

module app;

import common.cmd;

import std.algorithm.iteration;
import std.algorithm.mutation;
import std.exception;
import std.file;
import std.stdio;

enum APP_NAME = "cat";
enum APP_DESC = "Concatanate and display files.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["Marie-Joseph", "moon child"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("b", null, "Number non-blank lines from 1").name("b").optional);
		app.add(new Flag("e", null, "Display non-printing characters and end lines with '$'").name("e").optional);
		app.add(new Flag("l", null, "Set exclusive advisory lock").name("l").optional);
		app.add(new Flag("n", null, "Number lines from 1").name("n").optional);
		app.add(new Flag("s", null, "Squeeze adjacent empty lines").name("s").optional);
		app.add(new Flag("t", null, "Display non-printing characters and tabs as '^I'").name("t").optional);
		app.add(new Flag("u", null, "Disable output buffering").name("u").optional);
		app.add(new Flag("v", null, "Display non-printing characters").name("v").optional);
		app.add(new Argument("files", "File to catanate").name("files").optional.repeating);
	},
	(ProgramArgs args) {
		try {
			if (args.arg("files").length > 1) {
				foreach (fname; args.args("files")) {
					try {
						File fp = File(fname);
						fp.byChunk(4096).copy(stdout.lockingBinaryWriter);
					} catch (ErrnoException) {
						stderr.writeln(APP_NAME, ": file '", fname, "' not found");
						return 1;
					}
				}
			} else {
				stdin.byLine(KeepTerminator.yes).copy(stdout.lockingBinaryWriter);
			}
			return 0;
		} catch (Exception ex) {
			stderr.writeln(APP_NAME, ": ", ex.msg);
			return 1;
		}
	});
}
