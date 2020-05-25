/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	tty: Print the name of the tty running under.

	Written by: chaomodus
*/

module app;

import common.cmd;

import std.stdio;
import std.string;

enum APP_NAME = "tty";
enum APP_DESC = "Print the name of the tty the program is running under.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

extern (C) char* ttyname(int fd);

int main(string[] args) {
	return runApplication(args, (Program app) {
		app.add(new Flag("s", "silent", "Do not print any output.").name("silent").optional);
	},
	(ProgramArgs args) {
		try {
			char* tty = ttyname(stdout.fileno);

			if (!args.flag("silent")) {
				writeln(fromStringz(tty));
			}

			return 0;
		} catch (Exception e) {
			stderr.writeln(APP_NAME, ": ", e.msg);
			return 1;
		}
	});
}
