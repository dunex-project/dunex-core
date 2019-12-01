/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Author(s): chaomodus
	2019-11-28T23:45:00

	TODO:
	  Does not support pagination, headers, footers. Need to add argument to specify the pagination indicator character.
*/

enum NL_VERSION = "nl from dunex-core 1.0\nAuthor(s): chaomodus";

import common.escapes;

import std.conv;
import std.format;
import std.getopt;
import std.regex;
import std.stdio;
import std.string;

enum NMode { NONEMPTY, ALL, NONE, REGEX }

NMode bodyMode = NMode.NONEMPTY;
Regex!char bodyRegex;
NMode headerMode = NMode.NONE;
Regex!char headerRegex;
NMode footerMode = NMode.NONE;
Regex!char footerRegex;
string delimiter = "\t";
bool left_align = false;
uint incr = 1;
string option_numfmt = "";
uint number_width = 6;
string number_format = "%4d";
bool norestart = false;
size_t startnr = 1;
size_t blank_lines = 1;
string section_sep = "\:"

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

void process_oldstyle(string param, string value) {
  if (value == "ln") {
    left_align = true;
    number_format = "%d";
  } else if (value == "rn") {
    number_format = format("%%%dd", number_width);
  } else if (value == "rz") {
    number_format = format("%%0%dd", number_width);
  } else {
    throw new GetOptException("invalid line numbering format: must be ln, rn, rz");
  }
}

string format_number(bool ljust, string fmt, uint width, size_t number) {
  if (ljust)
    return leftJustify(format(fmt, number), width);
  return rightJustify(format(fmt, number), width);
}

int main(string[] args) {
  try {
    auto helpInformation = getopt(args,
				  std.getopt.config.passThrough,
				  std.getopt.config.bundling,
				  std.getopt.config.caseSensitive,
				  "b|body", "Body numbering style (a for all, t for non-empty, n for none, else a regular expression). Defaults to `t`.",
				  function void (string arg, string value) => process_mode_arg(&bodyMode, &bodyRegex, value),
				  "f|footer", "Footer numbering style. Defaults to `n`.", function void (string arg, string value) => process_mode_arg(&footerMode, &bodyRegex, value),
				  "h|header", "Header numbering style. Defaults to `n`.", function void (string arg, string value) => process_mode_arg(&headerMode, &headerRegex, value),
				  "s|separator", "The character to place between the count and the line. Defaults to `\\t`", &delimiter,
				  "i|incr", "The number to increment per line counted.", &incr,
				  "n|format", "POSIX-style format specifier (ln for left justified, rn for right justfied, rz for right just 0 padded). Defaults to `ln`", &process_oldstyle,
				  "p|no-page-restart", "Don't restart numbering on a logical page change.", &norestart,
				  "w|width", "Specify the width of the line number column. Defaults to `6`.", &number_width,
				  "v|startnum", "Specify the number to start when numbering lines in a page. Defaults to `1`.", &startnr,
				  "l|blank-lines", "Specify the number of blank lines to count as one blank line in `n` mode. Defaults to `1`.", &blank_lines,
				  "count-format", "The C-string style format to use to print the line numbers (default is %4d).", &option_numfmt,
				  "left-align", "Specify that the line number should be left aligned.", &left_align,
				  );
    if (helpInformation.helpWanted) {
      defaultGetoptPrinter(format("%s: print input with line numbers prepended.", args[0]),
			   helpInformation.options);
      return 1;
    }
  }
  catch (GetOptException e) {
    writeln(args[0], ": bad argument: ", e.msg);
    writeln("Try ", args[0], " --help for more information.");
    return 1;
  }

  delimiter = decode_escapes(delimiter);

  size_t bodycnt;
  size_t footercnt = 0;
  size_t headercnt = 0;
  bodycnt = startnr - 1;

  enum state {
	      BODY,
	      HEADER,
	      FOOTER
  }
  state readstate = state.BODY;
  File input = stdin;
  string line;
  string cntprefix;

  while (!input.eof) {
    line = input.readln();
    if (readstate == state.BODY) {
      if ((bodyMode == NMode.ALL) || ((bodyMode == NMode.NONEMPTY) && line.strip().length > 0) || ((bodyMode == NMode.REGEX) && (line.match(bodyRegex)))) {
	bodycnt += incr;
	cntprefix = format_number(left_align, number_format, number_width, bodycnt);
      }
      else
	cntprefix = "";
    } else if (readstate == state.FOOTER) {
      footercnt += 1;
    } else {
      headercnt += 1;
    }
    if (input.eof || !line)
      continue;
    write(cntprefix, delimiter, line);
  }


  return 0;
}
