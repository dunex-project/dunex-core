/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by: Marie-Joseph

	Bugs:

	Todo:
	* Implement flags

*/

module app;

import common.cmd;

import std.file : getcwd;
import std.stdio : stderr, writeln;

enum APP_NAME = "pwd";
enum APP_DESC = "Print the present working directory.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["Marie-Joseph"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
    return runApplication(args, (Program app) {
        app.add(new Flag("L", null, "Display logical present working directory").name("L").optional);
        app.add(new Flag("P", null, "Display physical present working directory").name("P").optional);
    },
    (ProgramArgs args) {
        try {
            writeln(getcwd);
        } catch (Exception ex) {
            stderr.writeln(APP_NAME, ": ", ex.msg);
            return 1;
        }
        return 0;
    });
}
