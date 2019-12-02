/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Written by: chaomodus
	2019-12-01T15:27:02

	Provide basic utilities for Discordian dates.

	TODO:
	  Operator overloading.
	  Formatting support / ddateFmt / localization.

*/

import common.ordinal;

import std.conv;
import std.datetime.date : Date;
import std.format;
import std.math;


enum DDayOfWeek : ubyte
{
  sm = 0,
  bt,
  pd,
  pp,
  so,
  ST
}

enum DSeason : ubyte
{
  chs = 1,
  dsc,
  cfn,
  bcy,
  afm,
}

static const string[] defaultDayNames = ["Sweetmorn", "Boomtime", "Pungenday", "Prickle-prickle", "Setting Orange"];
static const string[] defaultSeasonNames = ["Chaos", "Discord", "Confusion", "Bureaucracy", "The Aftermath"];
static const string defaultStTibbsDay = "St. Tibb's Day";

struct DDate {
public:
  bool isStTibbs;
  DSeason season;
  ubyte day;
  DDayOfWeek dayOfWeek;
  long year;

  @safe @nogc this(Date gregorianDate) {
    this.convert(gregorianDate);
  }

  @safe @nogc this(DSeason season, ubyte day, long year) {
    this.season = season;
    this.day = day;
    if (this.day == 0) {
      this.isStTibbs = true;
      this.dayOfWeek = DDayOfWeek.ST;
      return;
    }

    this.dayOfWeek = cast(DDayOfWeek)((this.dayOfYear % 5) + 1);
  }

  @safe @nogc this(bool isStTibbs, long year) {
    this.season = DSeason.chs;
    this.day = 0;
    this.dayOfWeek = DDayOfWeek.ST;
    this.isStTibbs = true;
  }

  @disable this();

  @safe @nogc void convert(Date gregorianDate) {
    this.year = gregorianDate.year + 1166;

    if ((gregorianDate.month == 2) && (gregorianDate.day == 29)) {
      this.isStTibbs = true;
      this.season = DSeason.chs;
      this.day = 0;
      this.dayOfWeek = DDayOfWeek.ST;
      return;
    }

    ushort doy = gregorianDate.dayOfYear;
    if ((gregorianDate.isLeapYear) && (gregorianDate.month > 2)) {
      doy -= 1;
    }

    this.season = cast(DSeason)((doy / 73) + 1);
    this.day = cast(ubyte)(doy - ((this.season - 1) * 73));
    this.dayOfWeek = cast(DDayOfWeek)((doy - 1 ) % 5);
  }

  @safe @nogc ushort dayOfYear() {
    if (this.isStTibbs)
      return cast(ushort)0;

    return cast(ushort)(((this.season - 1) * 73) + this.day);
  }

  @safe string toString() {
    if (this.isStTibbs) {
      return format("%s, YOLD %d", defaultStTibbsDay, this.year);
    }
    return format("%s the %s of %s, YOLD %d", defaultDayNames[cast(int)this.dayOfWeek], toOrdinal(this.day), defaultSeasonNames[cast(int)this.season-1], this.year);
  }

}

@safe unittest {
  assert(DDate(Date(2019, 1, 1)).year == 3185);
  assert(DDate(Date(2019, 1, 1)).season == DSeason.chs);
  assert(DDate(Date(2019, 1, 1)).dayOfWeek == DDayOfWeek.sm);
  assert(DDate(Date(2020, 2, 29)).isStTibbs);
}
