/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	basename: print the filename portion of a path name, optionally stripping a suffix
	Author(s): chaomodus
*/

module app;

import common.cmd;

import std.path : baseName;
import std.stdio : stderr, writeln;
import std.string : endsWith;

enum APP_NAME = "basename";
enum APP_DESC = "Print the filename portion of a path name.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("a", "multiple", "Process each argument as a path name.").name("multiple").optional);
		app.add(new Option("s", "suffix", "Specify a suffix to omit.").name("suffix").optional);
		app.add(new Argument("path", "The path(s) to process.").required.repeating);
	},
	(ProgramArgs args) {
		try {
			string suffix;
			string[] paths;

			if (args.flag("multiple")) {
				paths = args.args("path");
			} else {
				paths ~= [args.args("path")[0]];
			}

			if (args.option("suffix").length > 0) {
				suffix = args.option("suffix");
			} else if (!args.flag("multiple") && args.args("path").length == 2) {
				suffix = args.args("path")[1];
			}

			foreach (path; paths) {
				if (path.endsWith(suffix) && path != suffix) {
					path = path[1 .. $ - suffix.length];
				}
				writeln(baseName(path));
			}
			return 0;
		} catch (Exception e) {
			stderr.writeln(APP_NAME, ": ", e.msg);
			return 1;
		}
	});
}
