/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Author(s): chaomodus
	2019-12-19T20:06:15

	This implements translating file mode specifiers into mode_t

*/
module parsemode;

import std.conv;
import std.regex;
import std.string;

import core.sys.posix.sys.stat;

auto symbolic_mode_regex = ctRegex!("^(?P<acl>[aguo]*)(?P<app>[+=-])(?P<modes>[rwxst]+)$");

class PermParseException : Exception {
  @safe this(string msg, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
  }
}

/***********************************
 * parse a list of mode strings into a mode_t value.
 *
 * Params:
 *        string[] mode_spec = A list of mode specifiers, either as an octal number (three or four digits) or as a
 *                           series of symbolic strings in the form of [aguo][+=-][rwxst]. Symbolic modes
 *                           are applied to the base_mode parameter, while numeric modes nominally replace
 *                           base_mode. Mode manipulations are applied in order supplied.
 *
 *        mode_t base_mode = the starting mode to apply mode changes to as parsed. Default: 0644
 */
mode_t parseMode(const string[] mode_spec, mode_t base_mode = 420) {
  mode_t mode = base_mode;

  foreach (token; mode_spec) {
    if (token[0] == '0') {
      mode = to!mode_t(token, 8);
    }
    else {
      auto m = token.matchFirst(symbolic_mode_regex);
      if (!m || m.pre.length > 0 || m.post.length > 0) {
	throw new PermParseException("bad mode specifier " ~ token);
      }
      bool sid = false;
      bool sticky = false;
      mode_t basebits = 0;
      foreach (ch; m["modes"]) {
	switch (ch) {
	case 'r':
	  basebits = basebits | S_IRUSR;
	  break;
	case 'w':
	  basebits = basebits | S_IWUSR;
	  break;
	case 'x':
	  basebits = basebits | S_IXUSR;
	  break;
	case 't':
	  sticky = true;
	  break;
	case 's':
	  sid = true;
	  break;
	default:
	  continue;
	}
      }
      auto acl = m["acl"];
      if (!acl.length) {
	acl = "a";
      }
      mode_t newbits = 0;
      foreach (ch; acl) {
	switch (ch) {
	case 'u':
	  newbits = newbits | basebits;
	  if (sid) {
	    newbits = newbits | S_ISUID;
	  }
	  break;
	case 'a':
	  newbits = newbits | basebits | (basebits >> 3) | (basebits >> 6);
	  break;
	case 'g':
	  newbits = newbits | (basebits >> 3);
	  if (sid) {
	    newbits = newbits | S_ISGID;
	  }
	  break;
	case 'o':
	  newbits = newbits | (basebits >> 6);
	  break;
	default:
	  continue;
	}
      }
      if (sticky) {
	newbits = newbits | S_ISVTX;
      }
      switch (m["app"][0]) {
      case '=':
	mode = newbits;
	break;
      case '+':
	mode = mode | newbits;
	break;
      case '-':
	mode = mode & (~newbits);
	break;
      default:
	break;
      }
    }
  }
  return mode;
}

/***********************************
 * parse a mode string into a mode_t value. This is a proxy to parseMode(string[]).
 *
 * Params:
 *        string mode_spec
 *        mode_t base_mode
 */
mode_t parseMode(const string mode_spec, mode_t base_mode = 420) {
  return parseMode([mode_spec], base_mode);
}

unittest {
  import parsemode;

  assert(parseMode(["0644"], 0) == 420); // if base is 0, 0644 should be 420 dec.
  assert(parseMode(["0644", "000"]) == 0); // it should apply the perms in order
  assert(parseMode(["0000"]) == 0);
  assert(parseMode(["a+x"], 420) == 493); // add +x to all three perm groups
  assert(parseMode(["o=rx", "u+rw"], 0) == 389);
  assert(parseMode(["o=rx", "u+rw"]) == 389); // = operator should overwrite bits on base mode
  assert(parseMode(["+x"]) == parseMode(["a+x"]));

  assert(parseMode(["+x"]) == parseMode("+x"));
}
