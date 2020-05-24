/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	echo: Print arguments to stdout.
	Author(s): chaomodus
 */
module app;

import common.cmd;
import std.stdio;

enum APP_NAME = "echo";
enum APP_DESC = "Print arguments to stdout.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("n", null, "Omit newline at the end of input.").name("n").optional);
		app.add(new Argument("words", "Content to print to stdout.").name("words").repeating);
	},
	(ProgramArgs args) {
		try {
			foreach (i, s; args.args("words")) {
				stdout.write(s);
				if (i + 1 != args.args("words").length) {
					stdout.write(" ");
				}
			}
			if (!args.flag("n")) {
				stdout.write("\n");
			}
		} catch (Exception ex) {
			stderr.writeln(APP_NAME, ": ", ex.msg);
			return 1;
		}
		return 0;
	});
}


