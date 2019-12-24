/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Bugs:

	Todo:
	* implement -s
	* implement -d

*/

import std.stdio;
import std.string;

import common.cmd;

enum APP_NAME = "paste";
enum APP_DESC = "combine lines of files separtad by tabs";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["paste"];

int main(string[] args) {
  try {
    return runApplication(args, (Program app) {
	// app.add(new Flag("s", "serial", "Combine lines of files one at a time instead of all at once."));
	app.add(new Flag("z", "zero", "Write records separated by null instead of carriage return."));
	// app.add(new Option("d", "delimeters", "Use a sequence of delimeters (repeating) instead of tab."));
      },
      (ProgramArgs args, string[] leftovers) {
	File[] inputs;

	foreach (i; leftovers) {
	  writeln(i);
	  if (i == "-") {
	    inputs ~= stdin;
	  } else {
	    inputs ~= File(i, "r");
	  }
	}

	if (inputs.length == 0) {
	  inputs ~= stdin;
	}

	bool go = true;
	string line;
	while (go) {
	  go = false;
	  foreach (f; inputs) {
	    line = f.readln();
	    line = strip(line, ['\n']);
	    stdout.write(line);
	    stdout.write("\t");
	    go = go | (!f.eof);
	  }
	  if (args.flag("zero")) {
	    stdout.write("\0");
	  } else {
	    stdout.write("\n");
	  }
      }
	return 0;
      });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
