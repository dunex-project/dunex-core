/*
	Copyright (c) 2020, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	hostid: Print the 32 bit host id in hex.

	Author(s): chaomodus
 */

module app;

import common.cmd;

import std.format;
import std.stdio;

enum APP_NAME = "hostid";
enum APP_DESC = "Print the 32-bit host id number in hexadecimal.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

extern (C) ulong gethostid();

int main(string[] args) {
	return runApplication(args, (Program app) {}, (ProgramArgs args) {
		try {
			writeln(format("%08x", gethostid()));
			return 0;
		} catch (Exception e) {
			stderr.writeln(APP_NAME, ": ", e.msg);
			return 1;
		}
	});
}
