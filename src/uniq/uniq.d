/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Bugs:

	Todo:

*/

enum AUTHORS = "chaomodus";
enum VERSION = "0.0.0";
enum PROGRAM = "uniq";
enum SUMMARY = "filter out repeated lines in an input file";

import std.getopt;
import std.format;
import std.stdio;
import std.string;

int main(string[] args) {
  bool option_count = false;
  bool option_onlyrepeats = false;
  bool option_notrepeats = false;
  bool option_case_insensitive = false;

  uint option_fieldskip = 0;
  uint option_charskip = 0;

  auto helpInformation = getopt(args,
				std.getopt.config.passThrough,
				std.getopt.config.bundling,
				std.getopt.config.caseSensitive,
				"c|count", "Show the number of times each line is repeated.", &option_count,
				"d|onlyrepeats", "Only show lines that have one or more repeat.", &option_onlyrepeats,
				"u|norepeats", "Only show lines that do not have repeats.", &option_notrepeats,
				"i|case-insensitive", "Compare lines case-insensitively.", &option_case_insensitive,
				"f|fieldskip", "Skip n fields (blank deliminated tokens) before comparing lines.", &option_fieldskip,
				"s|charskip", "Skip n characters before comparing lines. This is applied after any field skip.", &option_charskip,
				);
  if (helpInformation.helpWanted) {
    defaultGetoptPrinter(format("%s: %s (version: %s)\n", args[0], SUMMARY, VERSION),
			 helpInformation.options);
    return 1;
  }

  string lastline;
  string line;
  uint lastline_count = 1;
  while (!stdin.eof) {
    line = stdin.readln();

    if (option_case_insensitive)
      line = line.toLower();

    if (lastline == line)
      lastline_count += 1;
    else {
      lastline_count = 1;
    }
    lastline = line;

    if (line)
      if (option_count)
	writeln(lastline_count, " ", line[0..$-1]);
      else
	writeln(line);
  }

  return 0;
}
