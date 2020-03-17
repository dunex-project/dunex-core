/*
	Copyright (c) 2019, 2020, DUNEX Contributors
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

module convert;

import common.ordinal;

import std.array;
import std.conv;
import std.datetime.date : Date;
import std.format;
import std.math;
import std.stdio;

enum DDayOfWeek : ubyte
{
  sm = 1,
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

static const string[6] defaultDayNames = ["Sweetmorn", "Boomtime", "Pungenday", "Prickle-prickle", "Setting Orange", "St. Tibb's Day"];
static const string[6] defaultShortDayNames = ["SM", "BT", "PD", "PP", "SO", "ST"];
static const string[5] defaultSeasonNames = ["Chaos", "Discord", "Confusion", "Bureaucracy", "The Aftermath"];
static const string[5] defaultShortSeasonNames = ["Chs", "Dsc", "Cfn", "Bcy", "Afm"];
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

    this.dayOfWeek = cast(DDayOfWeek)(this.dayOfYear % 5);
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
    auto doy = gregorianDate.dayOfYear - 1;
    if ((gregorianDate.isLeapYear) && (gregorianDate.month > 2)) {
      doy -= 1;
    }
    
    this.season = cast(DSeason)((doy / 73) + 1);
    this.day = cast(ubyte)((doy - ((this.season - 1) * 73)) + 1);
    this.dayOfWeek = cast(DDayOfWeek)((doy % 5) + 1);
  }

  /// Return the day of the year.
  @safe @nogc ushort dayOfYear() {
    if (this.isStTibbs)
      return cast(ushort)0;

    return cast(ushort)((this.season * 73) + this.day);
  }

  /// Support object protocol.
  @safe string toString() const {
    return this.toESO1dd1293();
  }

  
  /// Convert to ESO 1dd1293 standard format
  @safe string toESO1dd1293() const {
    if (this.isStTibbs) {
      return std.format.format("%s, YOLD %d", defaultStTibbsDay, this.year);
    }
    return this.format("%W the %o of the season of %S, YOLD %y");    
  }
  
  /*
   * Formatting support
   *
   * Formats:
   *   %n - Season number from 1 to 5
   *   %S - Season name
   *   %r - short season name
   *   %w - day of week number from 1 to 5
   *   %W - day of week name
   *   %R - short day of week name
   *   %d - day number of season
   *   %o - ordinal ("Nth") day number of season
   *   %y - year number
   *
   */
  @safe string format(string inStr) const {
    @safe void pad(scope void delegate(string) @safe sink, string padding, uint count) {
      for (int i = 0; i < count; i++) {
  	sink(padding);
      }
    }
    @safe void padTo(scope void delegate(string) @safe sink, string padding, uint count, int value) {
      auto s = to!string(value);
      uint n = cast(uint)(count - s.length);
      if ((count != 0) && (n > 0)) {
  	pad(sink, padding, n);
      }
      sink(s);
    }
    
    auto fmt = FormatSpec!char(inStr);

    auto writer = Appender!string();
    writer.reserve(inStr.length);
    @safe auto sink = (string x) => writer.put(x);
    while (fmt.writeUpToNextSpec(writer)) {
      auto padding  = " ";
      if (fmt.flZero) {
	padding = "0";
      }
      switch (fmt.spec) {
      case 'D':
      case 's':
	sink(this.toString());
	break;
      case 'n':
	padTo(sink, padding, fmt.width, cast(int)this.season);
	break;
      case 'S':
	sink(defaultSeasonNames[cast(int)this.season - 1]);
	break;
      case 'r':
	sink(defaultShortSeasonNames[cast(int)this.season - 1]);
	break;
      case 'w':
	sink(to!string(cast(uint)this.dayOfWeek));
	break;
      case 'W':
      sink(defaultDayNames[cast(int)this.dayOfWeek-1]);
      break;
      case 'R':
	sink(defaultShortDayNames[cast(int)this.dayOfWeek-1]);
	break;
    case 'd':
      padTo(sink, padding, fmt.width, cast(int)this.day);
      break;
      case 'o':
	sink(toOrdinal(cast(int)this.day));
	break;
      case 'y':
	padTo(sink, padding, fmt.width, cast(int)this.year);
	break;
      default:
	throw new Exception("Unknown format specifier: %" ~ fmt.spec);
      }      
    }
    return to!string(writer.data);
  }
}

@safe unittest {
  assert(DDate(Date(2019, 1, 1)).year == 3185);
  assert(DDate(Date(2019, 1, 1)).season == DSeason.chs);
  assert(DDate(Date(2019, 1, 1)).dayOfWeek == DDayOfWeek.sm);
  assert(DDate(Date(2020, 2, 29)).isStTibbs);
}
