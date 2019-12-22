/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Bugs:

	Todo:

*/

import core.sys.posix.sys.stat : umask, mkfifo, mode_t, chmod;
import core.stdc.errno : errno;
import core.stdc.string : strerror;

import std.conv;
import std.format;
import std.stdio;
import std.string;

import common.cmd;
import common.parsemode;

enum APP_NAME = "mkfifo";
enum APP_DESC = "Create a named pipe (fifo)";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["mkfifo"];

int main(string[] args) {
  try {
    mode_t base_mode = umask(0);
    umask(base_mode);
    base_mode = octal!"666" & (~base_mode);

    return runApplication(args, (Program app) {
	app.add(new Argument("fifo", "The path to create."));
	app.add(new Option("m", "mode", "Mode to create the fifo as. Default: 0666 - umask").defaultValue(""));
      },
      (ProgramArgs args) {
	mode_t target_mode = base_mode;
	if (args.option("mode").length > 0) {
	  target_mode = parseMode(args.option("mode"), base_mode);
	}
	// nasty ol libc style
	int result = mkfifo(args.arg("fifo").toStringz, target_mode);
	if (result != 0) {
	  throw new Exception(format("failed to create: %s", strerror(errno()).fromStringz));
	}
	if (target_mode != base_mode) {
	  // mkfifo() does not allow perms outside of the umask, so we fix it here.
	  result = chmod(args.arg("fifo").toStringz, target_mode);
	  if (result != 0) {
	    throw new Exception(format("failed to chmod target: %s", strerror(errno()).fromStringz));
	  }
	}
	return result;
      });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
