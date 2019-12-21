/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Author(s): chaomodus
	2019-12-01T20:03:55

	This implements converting a numeric to a heap-allocated string with its ordinal.

	TODO:
	  Support localization (this is completely different in non-English languages).
*/
module ordinal;
import std.format;

@safe toOrdinal(long n) {
  static const string[] suffixes = ["th", "st", "nd", "rd"];
  auto ord = n % 100;

  if (ord / 10 == 1)
    ord = 0;
  ord = ord % 10;
  if (ord > 3)
    ord = 0;

  return format("%d%s", n, suffixes[ord]);
}

unittest {
  assert(true);
}
