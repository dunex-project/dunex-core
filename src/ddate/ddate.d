/*
	Copyright (c) 2019, 2020, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by: chaomodus
	2019-12-01T15:27:02

	Provide UI for discordian date.

	TODO:
	  i18n

*/

module app;

import common.cmd;
import convert;

import std.datetime.date : Date;
import std.datetime.systime: Clock;
import std.stdio : stderr, writeln;
import std.format;

enum APP_NAME = "ddate";
enum APP_DESC = "convert current date into Discordian date

  Format support:
  %D - ESO 1dd1293 standard format (default)
  %n - Season number from 1 to 5
  %S - Season name
  %r - short season name
  %w - day of week number from 1 to 5
  %W - day of week name
  %R - short day of week name
  %d - day number of season
  %o - ordinal ('Nth') day number of season
  %y - year number


";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["chaomodus"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = ["ddate"];

int main(string[] args) {
  try {
    return runApplication(args, (Program app) {
	app.add(new Argument("format", "A format to print out the date in.").optional);
      },
      (ProgramArgs args, string[] leftovers) {
	auto ddate = DDate(cast(Date)Clock.currTime);
	if (args.arg("format")) {
	  writeln(ddate.format(args.arg("format")));
	} else {
	  writeln(ddate);
	}
	return 0;
      });
    } catch(Exception ex) {
    stderr.writeln(APP_NAME, ": ", ex.msg);
    return 1;
  }

}
