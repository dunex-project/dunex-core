/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by:

	Bugs:

	Todo:
	* i18n boilerplate

*/

module app;

import common.cmd;

// Name of the executable or core functional name
enum APP_NAME = "appname";
// Short description of the app.
enum APP_DESC = "Description of app";
// App internal version
enum APP_VERSION = "1.0 (dunex-core)";
// A list of author ids
enum APP_AUTHORS = [];
// The license for this particular app
enum APP_LICENSE = import("COPYING");
// A list of this app's capabilities
enum APP_CAP = [APP_NAME];

int main(string[] args) {
  try {
    return runApplication(args, (Program app) {
	// app.add(new Argument("path", "the path(s) to print the directory part of").optional.repeating); For example, add an argument to the command parser,
	// See https://github.com/robik/commandr for documentation on that.
      },
      (ProgramArgs args) {
0	// Process args additionally, and then perform app things (fill in with the functional part of app)
      }
      return 0;
    });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
