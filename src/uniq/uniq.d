/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Bugs:

	Todo:

*/

import std.format;
import std.stdio;
import std.string;

import common.cmd;

enum APP_NAME = "uniq";
enum APP_DESC = "Manipulate repeated lines in input";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["uniq"];


int main(string[] args) {
  try {
    return runApplication(args, (Program app) {
	app.add(new Argument("input", "The path to take input from (default is -, which means stdin)").defaultValue("-"));
	app.add(new Argument("output", "The path to return output to").defaultValue("-"));
	app.add(new Flag("c", "count", "Show the number of times each line repeats."));
	app.add(new Flag("d", "onlyrepeats", "Only show lines that have one or more repeats."));
	app.add(new Flag("u", "norepeats", "Only show lines that do not have repeats."));
	app.add(new Flag("i", "insensitive", "Compare lines case-insensitively."));
	app.add(new Option("f", "fieldskip", "Skip n blank-delimited fields.").defaultValue("0"));
	app.add(new Option("s", "charskip", "Skip n characters before comparing lines. Applied after field skip.").defaultValue("0"));
      },
      (ProgramArgs args) {
	string lastline;
	string line;
	uint lastline_count = 1;
	while (!stdin.eof) {
	  line = stdin.readln();

	  if (args.flag("insensitive"))
	    line = line.toLower();

	  if (lastline == line)
	    lastline_count += 1;
	  else {
	    lastline_count = 1;
	  }
	  lastline = line;

	  if (line) {
	    if (args.flag("count"))
	      {
		writeln(lastline_count, " ", line[0..$-1]);
	      }
	    else {
	      writeln(line);
	    }
	  }
	}
	return 0;
      });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
