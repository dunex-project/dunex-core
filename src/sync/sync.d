/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	sync: call sync system call to flush buffers to disk
	Author(s): chaomodus
*/

module app;

import common.cmd;

import core.sys.posix.unistd : sync;
import std.stdio : stderr, writeln;

enum APP_NAME = "sync";
enum APP_DESC = "Synchronize cached writes to persistant storage.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
	return runApplication(args, (Program app) {}, (ProgramArgs args) {
	    try {
	        sync();
	    } catch (Exception ex) {
            stderr.writeln(APP_NAME, ": ", ex.msg);
            return 1;
        }
        return 0;
	});
}
