/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	false / true / return: Exit with true, false or specified value.

	Author(s): chaomodus
*/

module app;

import common.cmd;

import std.algorithm;
import std.conv;
import std.stdio;

enum APP_NAME = "return";
enum APP_DESC = "Return true, false, or a specified numeric value.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
    string givenName = args[0];
    return runApplication(args, (Program app) {
        app.add(new Argument("value", "A numeric value to be returned.").optional);
    },
    (ProgramArgs args) {
        try {
            if (givenName.endsWith("false")) {
                return 1;
            } else if (givenName.endsWith("true")) {
                return 0;
            }

            int retval;
            if (args.arg("value").length != 0) {
            // if return's argument is a non-integer, then it is ignored and 0 returned
                try {
                    retval = to!int(args.arg("value"));
                } catch (Throwable) {}
            }

            return retval;
        } catch (Exception e) {
            stderr.writeln(APP_NAME, ": ", e.msg);
            return 1;
        }
    });
}
