/*
	Copyright (c) 2020, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	yes: Repeatedly print specified string.

	Written by: chaomodus and Marie-Joseph
*/

module app;

import common.cmd;
import common.escapes;

import std.stdio : write, stderr;
import std.array : join;

enum APP_NAME = "yes";
enum APP_DESC = "Repeatedly print the specified string or 'y'.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus", "Marie-Joseph"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["yes"];

int main(string[] args) {
    return runApplication(args, (Program app) {
            app.add(new Argument("string", "the string to print repeatedly").optional.repeating);
            app.add(new Flag("n", "no-newline", "omit newline character when printing").name("noNewline"));
        },
        (ProgramArgs args) {
            try {
                string nl = args.flag("noNewline") ? "" : "\n";
                string argsToPrint = args.arg("string").length == 0 ? "y" : decodeEscapes(args.args("string").join(" "));

                while (true)
                    write(argsToPrint, nl);

            } catch(Exception ex) {
                stderr.writeln(APP_NAME, ": ", ex.msg);
                return 1;
            }
        }
    );
}
