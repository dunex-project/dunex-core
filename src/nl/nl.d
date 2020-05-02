/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Author(s): chaomodus
	2019-11-28T23:45:00

	TODO:
	  blank line folding
*/

module app;

import std.conv;
import std.format;
import std.regex;
import std.stdio;
import std.string;

import common.cmd;
import common.escapes;

enum APP_NAME = "nl";
enum APP_DESC = "Print line numbers";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

enum NMode { NONEMPTY, ALL, NONE, REGEX }
enum NState { BODY, HEADER, FOOTER, NONE }

bool left_align;
uint number_width;
string number_format;

void process_mode_arg(NMode *nmode, Regex!char *nregex, string value) {
  if (value == "a")
    *nmode = NMode.ALL;
  else if (value == "t")
    *nmode = NMode.NONEMPTY;
  else if (value == "n")
    *nmode = NMode.NONE;
  else {
    *nmode = NMode.REGEX;

    *nregex = regex(value);
  }
}

void process_oldstyle(string value) {
  if (value == "ln") {
    left_align = true;
    number_format = "%d";
  } else if (value == "rn") {
    left_align = false;
    number_format = format("%%%dd", number_width);
  } else if (value == "rz") {
    left_align = false;
    number_format = format("%%0%dd", number_width);
  } else {
    throw new Exception("invalid line numbering format: must be ln, rn, rz");
  }
}

string format_number(bool ljust, string fmt, uint width, size_t number) {
  if (ljust)
    return leftJustify(format(fmt, number), width);
  return rightJustify(format(fmt, number), width);
}

NState is_section_delimiter(string line, string delim) {
  if (!line.startsWith(delim))
    return NState.NONE;

  if (line == delim ~ "\n")
    return NState.FOOTER;
  if (line == delim ~ delim ~ "\n")
    return NState.BODY;
  if (line == delim ~ delim ~ delim ~ "\n")
    return NState.HEADER;

  return NState.NONE;
}

int main(string[] args) {
  try {
    return runApplication(args, (Program app) {
	app.add(new Option("b", "body", "Body numbering style (a for all, t for non-empty, n for none, else a regular expression) Default: t.").defaultValue("t"));
	app.add(new Option("f", "footer", "Footer numbering style, as above. Default: n").defaultValue("n"));
	app.add(new Option("r", "header", "Header numbering style, as above. Default: n").defaultValue("n"));
	app.add(new Option("s", "separator", "The character to place between the count and the line. Default: '\\t'").defaultValue("\t"));
	app.add(new Option("i", "incr", "The number to increment per line counted.").defaultValue("1"));
	app.add(new Option("n", "format", "POSIX-style format specifier (ln for left justified, rn for right justfied, rz for right just 0 padded). Default: rn").acceptsValues(["ln", "rn", "rz"]).defaultValue("rn"));
	app.add(new Option("w", "width", "Specify the width of the number column.").defaultValue("6"));
	app.add(new Option("v", "startnum", "Specify the number to start with when numbering lines in a page.").defaultValue("1"));
	app.add(new Option("l", "blanklines", "Specify the number of blank lines to count as one blank line in 'n' mode.").defaultValue("1"));
	app.add(new Option(null, "countformat", "Specify the C-style format to use to print the line numbers."));
	app.add(new Option("d", "delim", "Specify the section delimiter. Default: ::").defaultValue("::"));
	app.add(new Flag("p", "nopagerestart", "Don't restart numbering on a logical page change."));
	app.add(new Flag(null, "leftalign", "Specify that the line number should be left aligned."));
      },
      (ProgramArgs args) {
	// Process arguments
	NMode bodyMode = NMode.NONEMPTY;
	Regex!char bodyRegex;
	NMode headerMode = NMode.NONE;
	Regex!char headerRegex;
	NMode footerMode = NMode.NONE;
	Regex!char footerRegex;

	process_mode_arg(&bodyMode, &bodyRegex, args.option("body"));
	process_mode_arg(&footerMode, &footerRegex, args.option("footer"));
	process_mode_arg(&headerMode, &headerRegex, args.option("header"));
	string separator = decodeEscapes(args.option("separator"));
	bool norestart = args.flag("nopagerestart");
	if (args.flag("leftalign"))
	  left_align = true;
	size_t startnr = to!size_t(args.option("startnum"));
	size_t blank_lines = to!size_t(args.option("blanklines"));
	uint incr = to!uint(args.option("incr"));
	string delimiter = args.option("delim");
	number_width = to!uint(args.option("width"));
 	process_oldstyle(args.option("format"));
	// count-format overrides many of the above
	if (args.option("countformat"))
	  number_format = args.option("countformat");
	// Done with args.

	size_t bodycnt;
	size_t footercnt = 0;
	size_t headercnt = 0;
	bodycnt = startnr - 1;

	NState readNState = NState.BODY;
	NState nextNState;
	File input = stdin;
	string line;
	string cntprefix;

	while (!input.eof) {
	  line = input.readln();
	  nextNState = is_section_delimiter(line, delimiter);
	  if (nextNState != NState.NONE) {
	    readNState = nextNState;
	    footercnt = 0;
	    headercnt = 0;
	    if ((nextNState == NState.BODY) && !norestart)
	      bodycnt = 0;
	    continue;
	  }
	  if (readNState == NState.BODY) {
	    if ((bodyMode == NMode.ALL) || ((bodyMode == NMode.NONEMPTY) && line.strip().length > 0) || ((bodyMode == NMode.REGEX) && (line.match(bodyRegex)))) {
	      bodycnt += incr;
	      cntprefix = format_number(left_align, number_format, number_width, bodycnt);
	    }
	    else
	      cntprefix = "";
	  } else if (readNState == NState.FOOTER) {
	    if ((footerMode == NMode.ALL) || ((footerMode == NMode.NONEMPTY) && line.strip().length > 0) || ((footerMode == NMode.REGEX) && (line.match(footerRegex)))) {
	      footercnt += incr;
	      cntprefix = format_number(left_align, number_format, number_width, footercnt);
	    }
	    else
	      cntprefix = "";
	  } else {
	    if ((headerMode == NMode.ALL) || ((headerMode == NMode.NONEMPTY) && line.strip().length > 0) || ((headerMode == NMode.REGEX) && (line.match(headerRegex)))) {
	      headercnt += incr;
	      cntprefix = format_number(left_align, number_format, number_width, headercnt);
	    }
	    else
	      cntprefix = "";
	  }
	  if (input.eof || !line)
	    continue;
	  write(cntprefix, separator, line);
	}
	return 0;
      });
  } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }
}
