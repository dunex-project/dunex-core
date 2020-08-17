/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	seq: output a sequence of numbers
	Author(s): chaomodus

	Bugs:
		Does not support full character escapes, just letter ones and \0.
 */
module app;

import common.cmd;
import common.escapes;

import std.array;
import std.algorithm;
import std.conv;
import std.format;
import std.stdio;

enum APP_NAME = "seq";
enum APP_DESC = "Output a sequence of numbers";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {
        app.add(new Argument("values", "[first [incr]] last; first defaults to 0 and incr defaults to 1").required.repeating);
        app.add(new Option("f", "format", "specify printf(3)-style format to print values").name("format").optional.defaultValue("%g"));
        app.add(new Option("s", "separator", "specify separator to place between each number").name("separator").optional.defaultValue("\n"));
        app.add(new Option("t", "terminal", "specify the terminating character to print").name("terminal").optional);
        app.add(new Flag("w", "fixed-width", "pad numbers to equal width").name("fixedWidth").optional);
    },
    (ProgramArgs args) {
        try {
			real first = 0;
			real incr = 1;
			real last;

			if (args.args("values").length > 1)
				first = to!real(args.args("values")[0]);
			if (args.args("values").length == 3)
				incr = to!real(args.args("values")[1]);
			last = to!real(args.args("values")[$ - 1]);

			string fmt = args.option("format");
			string separator = args.option("separator");
			string terminal = args.option("terminal");

			if (first > last) {
				if (incr > 0)
					incr = incr * -1;
			}

			ulong maxwidth;
			maxwidth = format(fmt, max(first, last)).length;
			if (args.flag("fixedWidth")) {
				fmt = format("%%0%dg", maxwidth);
			}

			separator = decodeEscapes(separator);
			if (terminal.length == 0)
				terminal = separator;
			else
				terminal = decodeEscapes(terminal);

			real seq;
			for (seq = first; (incr < 0) ? (seq + incr >= last) : (seq + incr <= last); seq += incr) {
				stdout.write(format(fmt, seq));
				stdout.write(separator);
			}
			stdout.write(format(fmt, seq));
			stdout.write(terminal);

			return 0;
        } catch(Exception ex) {
            stderr.writeln(APP_NAME, ": ", ex.msg);
            return 1;
        }
    });
}
