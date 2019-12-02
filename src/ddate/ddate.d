/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by: chaomodus
	2019-12-01T15:27:02

	Provide UI for discordian date.

	TODO:
	  i18n

*/



import convert;

import std.datetime.date : Date;
import std.datetime.systime: Clock;
import std.stdio : writeln;

int main(string[] args) {
  writeln(DDate(cast(Date)Clock.currTime));
  return 0;
}
