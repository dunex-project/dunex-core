/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	cut: Print specified portions of input lines.
	Author(s): chaomodus

	Extension from standard:
		We accept an arbitrary number of ranges as if they are joined with ,
		We take the last specified type of range as the one to use.
		We accept multi-character delimeters.
		We can accept a regex as a delimiter if -r is passed.
		A joining character can be specified with -j.
	Bugs:
		Treats characters as 1 byte each.
*/

import std.exception;
import std.stdio;
import std.string;
import std.getopt;
import std.conv;
import std.regex;
import std.algorithm.searching;

enum modeEnum {
	chars,
	fields,
};

class NullableException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
};

class RangeSpanException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
};

struct Nullable(T) {
	T _value;
	bool _novalue;

	void nullify() {
		this._novalue = true;
	}

	@property bool isnull() {
		return this._novalue;
	}

	@property T value() {
		if (!this._novalue) {
			return this._value;
		}
		throw new NullableException("value is null");
	}

	@property void value(T newvalue) {
		this._novalue = false;
		this._value = newvalue;
	}

	string toString() {
		if (this.isnull) {
			return "null";
		}
		return text(this.value);
	}
}

struct RangeSpan {
	bool isrange = true;
	Nullable!uint start;
	Nullable!uint end;
};

// GLOBALS
auto range_regex = ctRegex!(`^(?P<start>\d+)?(?P<hy>-)?(?P<end>\d+)?$`);
auto whitespace_regex = ctRegex!(`[\t ]+`);
modeEnum mode;
RangeSpan[] output_range;
Nullable!string joiner;

RangeSpan[] process_range(string range) {
	string[] ranges = range.split(",");
	RangeSpan[] output;

	foreach (r; ranges) {
		auto m = r.match(range_regex).captures;
		if (m.empty) {
			throw new RangeSpanException(format("invalid range %s", r));
		}
		RangeSpan outr;

		if (m["start"].length) {
			outr.start.value(to!uint(m["start"]));
			if (outr.start.value == 0) {
				throw new RangeSpanException("ranges start at 1");
			}
			outr.start.value(outr.start.value - 1);
		} else {
			outr.start.value(0);
		}

		outr.isrange = (m["hy"] == "-");

		if (m["end"].length) {
			outr.end.value(to!uint(m["end"]) - 1);
			if (outr.end.value < outr.start.value) {
				throw new RangeSpanException("range must start with a lower number than it ends with");
			}
		} else {
			outr.end.nullify;
		}
		output ~= outr;
	}
	return output;
}

void process_range_args(string arg, string value) {
	if (arg == "c|chars|b|bytes") {
		mode = modeEnum.chars;
	} else {
		mode = modeEnum.fields;
	}
	output_range ~= process_range(value);
}

void process_join_args(string arge, string value) {
	joiner.value(value);
}

T[] array_range_slice(T)(T[] input, RangeSpan[] ranges) {
	T[] output;
	foreach (r; ranges) {
		if (r.start.value >= input.length) {
			continue;
		}
		if (r.isrange) {
			if (r.end.isnull || r.end.value + 1 >= input.length) {
				output ~= input[r.start.value .. $];
			} else {
				output ~= input[r.start.value .. r.end.value + 1];
			}
		} else {
			output ~= input[r.start.value];
		}
	}
	return output;
}

string process_chars(string input, RangeSpan[] ranges) {
	if (input)
		return to!string(array_range_slice!char(to!(char[])(input), ranges));
	return "";
}

string process_fields(string input, string delim, RangeSpan[] ranges, Nullable!string joiner) {
	auto splitted = input.split(delim);
	auto output = array_range_slice!string(splitted, ranges);
	if (joiner.isnull)
		return join(output, delim);
	else
		return join(output, joiner.value);
}

string process_regex(string input, Regex!char delim, RangeSpan[] ranges, Nullable!string joiner) {

	auto splitted = std.regex.split(input, delim);
	auto output = array_range_slice!string(splitted, ranges);
	if (joiner.isnull)
		return join(output, " ");
	else
		return join(output, joiner.value);
}

int main(string[] args) {
	string delim = "\t";
	bool suppress;
	bool whitespace;
	bool use_regex;
	Regex!char delim_regex;

	joiner.nullify;

	try {
		auto helpInformation = getopt(args, std.getopt.config.passThrough, 
			"c|chars|b|bytes", "Specify which chars (or bytes) to print.", &process_range_args,
			"f|fields", "Specify which fields to print.", &process_range_args, 
			"d|delimiter", "Specify the delimiter to use for fields (default is TAB).", &delim, 
			"s|suppress", "Suppress lines not containing a delimiter.", &suppress, 
			"w|whitespace", "Use whitespace (space and tab) as a delimiter and strip repeats.", &whitespace,
			"r|regex", "Interpret the delimiter as a regex to split on.", &use_regex, 
			"j|join", "Specify the string to join fields on (default is the delimiter unless the delimiter is a regex, and then its space).", &process_join_args
		);
		if (helpInformation.helpWanted) {
			defaultGetoptPrinter("Print portions of input lines.", helpInformation.options);
			return 1;
		}
	} catch (RangeSpanException e) {
		writeln(args[0], ": ", e.msg);
		return 1;
	}

	auto input = stdin;
	try {
		if ((args.length > 1) && (args[1] != "-")) {
			input = File(args[1], "r");
		}
	} catch (ErrnoException e) {
		writeln(args[0], ": ", e.msg);
		return 1;
	}

	if (use_regex) {
		try {
			delim_regex = regex!(string)(delim);
		} catch (RegexException e) {
			writeln(args[0], ": ", e.msg);
			return 1;
		}
	}

	string line;

	while (!input.eof) {
		line = input.readln().strip();

		if (whitespace) {
			writeln(process_regex(line, whitespace_regex, output_range, joiner));
		} else if (use_regex) {
			writeln(process_regex(line, delim_regex, output_range, joiner));
		} else if (mode == modeEnum.fields) {
			if (suppress && !line.canFind(delim)) {
				continue;
			}
			writeln(process_fields(line, delim, output_range, joiner));
		} else if (mode == modeEnum.chars) {
			writeln(process_chars(line, output_range));
		}
	}

	return 0;

}
