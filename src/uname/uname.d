/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	uname: Print information about the operating system.

	Written by: chaomodus
*/

module app;

import common.cmd;

import core.stdc.errno;
import core.sys.posix.sys.utsname;
import std.algorithm : canFind;
import std.stdio;
import std.string;

enum APP_NAME = "uname";
enum APP_DESC = "Print information about the operating system.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("a", null, "Behave as though '-s -n -r -v -m' were specified.").name("a").optional);
		app.add(new Flag("m", null, "Print the machine architecture.").name("m").optional);
		app.add(new Flag("n", null, "Print the name of the system.").name("n").optional);
		app.add(new Flag("o", null, "Synonym of -s for compatibility.").name("o").optional);
		app.add(new Flag("r", null, "Print the current kernel release.").name("r").optional);
		app.add(new Flag("s", null, "Print the name of the operating system (default).").name("s").optional);
		app.add(new Flag("v", null, "Print the version of this OS.").name("v").optional);
	},
	(ProgramArgs args) {
		try {
			utsname info;
			int result = core.sys.posix.sys.utsname.uname(&info);

			if (result != 0)
				throw new Exception("invalid system information buffer");

			if (args.flag("a")) {
				stdout.writeln(info.sysname, " ", info.nodename, " ", info.release, " ", info.version_, " ", info.machine);
			} else {
				bool written = false;

				if (args.flag("s") || args.flag("o")) {
					stdout.write(info.sysname, " ");
					written = true;
				}

				if (args.flag("n")) {
					stdout.write(info.nodename, " ");
					written = true;
				}

				if (args.flag("r")) {
					stdout.write(info.release, " ");
					written = true;
				}

				if (args.flag("v")) {
					stdout.write(info.version_, " ");
					written = true;
				}

				if (args.flag("m")) {
					stdout.write(info.machine, " ");
					written = true;
				}

				if (!written)
					stdout.writeln(info.sysname);
				else
					stdout.write("\b \b\n");
			}
			return 0;
		} catch (Exception e) {
			stderr.writeln(APP_NAME, ": ", e.msg);
			return 1;
		}
	});
}
