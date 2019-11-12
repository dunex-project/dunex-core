/*
  sleep: Suspend execution for a specific amount of time.

  Written by: chaomodus
  2019-11-03T13:32:46

  Bugs:
    BSD sleep does an interesting thing where it prints out remaining time on signal.
*/

import core.sys.posix.unistd: sleep, usleep;
import std.conv;
import std.math;
import std.stdio;
import std.regex;

auto intervalRegex = ctRegex!(`^(?P<value>\d+(\.\d+)?)(?P<unit>[mhsudM])$`);

int main(string[] args) {
  double totaltime = 0;
  uint usecs = 0;

  if (args.length == 1) {
    writeln(args[0],": suspend execution for specified time.\nNeed at least one time period argument.");
    return 1;
  }

  foreach (arg; args[1..$]) {
    string val;
    string unit;
    auto matchresult = arg.match(intervalRegex).captures;
    if (matchresult.empty) {
      val = arg;
      unit = "s";
    } else {
      val = matchresult["value"];
      unit = matchresult["unit"];
    }
    float mult;

    switch (unit) {
    case "m":
      mult = 60.0;
      break;
    case "h":
      mult = 3600.0;
      break;
    case "s":
      mult = 1.0;
      break;
    case "u":
      mult = 0;
      usecs += to!uint(val);
      break;
    case "d":
      mult = 86400.0;
      break;
    case "M":
      mult = 2629800.0;
      break;
    default:
      break;
    }
    totaltime += to!double(val) * mult;
  }

  usecs += to!int((totaltime - floor(totaltime)) * 1000000);

  if (totaltime > 0)
    sleep(to!uint(floor(totaltime)));
  if (usecs > 0)
    usleep(to!uint(usecs));

  return 0;
}
