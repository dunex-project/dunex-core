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

import std.getopt;
import std.path : baseName;
import std.stdio;
import std.string;

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
		app.add(new Argument("suffix", "Optional suffix to omit.").optional)
	},
	(ProgramArgs args) {
		try {
			if (args.flag("multiple") || args.option("suffix").length > 0) {

			} else {
				foreach (path; args.args("path")) {
					if (args.arg("suffix").length > 0 && path.endsWith(args.arg("suffix"))) {
						writeln(baseName(path[0 .. $ - args.arg("suffix").length]));
					} else {
						writeln(baseName(path));
					}
				}

			}


			bool multiple = false;
			string suffix;
			string[] paths;
			auto helpInformation = getopt(args, std.getopt.config.passThrough,
				"a|multiple", "Process each argument as a path name.", &multiple,
				"s|suffix", "Specify a suffix in -a mode.", &suffix
			);

			if (helpInformation.helpWanted) {
				defaultGetoptPrinter("Print the basename portion of a path.", helpInformation.options);
				return 1;
			}

			if (multiple) {
				if (!(args.length >= 2)) {
					writeln(args[0], ": specify at least one path.");
					return 1;
				}
				paths = args[1 .. $];
			} else {
				if (args.length < 2) {
					writeln(args[0], ": specify a path name.");
					return 1;
				} else if (args.length > 3) {
					writeln(args[0], ": too many arguments. Specify a path name and optional suffix.");
					return 1;
				}
				paths ~= [args[1]];
				if (args.length == 3) {
					suffix = args[2];
				}
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
