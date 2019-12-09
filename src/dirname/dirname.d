/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	basename: print directory part of the specified path
	Author(s): chaomodus
*/

module app;

import std.path : dirName;
import std.stdio;

import common.cmd;

enum APP_NAME = "hostname";
enum APP_DESC = "Print directory part of specified path.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["dirname"];

int main(string[] args) {
  try {
  return runApplication(args, (Program app) {
      app.add(new Argument("path", "the path(s) to print the directory part of").optional.repeating);
    },
    (ProgramArgs args) {
      if (args.args("path").length == 0)
	throw new Exception("specify at least one path");
      foreach (path; args.args("path")) {
	writeln(dirName(path));
      }
      return 0;
    });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
