/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	wc: Count characters, lines, etc.
	Author(s): chaomodus

	Bugs:
		Word count seems to be different from how GNU util counts words.
		Max-line-length seems to be different from GNU util.
*/

import std.getopt;
import std.stdio;
import std.regex;
import std.string;
import std.conv;
import std.algorithm.searching;

auto whitespace_regex = ctRegex!(`[\t ]+`);

struct FileStats {
	string fname;
	File file;
	ulong char_count;
	ulong line_count;
	ulong word_count;
	ulong max_line_length;

	void doCount() {
		while (!this.file.eof) {
			auto line = this.file.readln();

			if (line.length > this.max_line_length) {
				this.max_line_length = line.length;
			}
			if (line.canFind("\n") || line.canFind("\r")) {
				this.line_count += 1;
			}
			this.char_count += line.length;
			string[] words = line.split(whitespace_regex);
			this.word_count += words.length;
		}
	}
};

int main(string[] args) {
	bool show_chars = true, show_lines = true, show_words = true, show_line_lengths = false;
	bool seen_chars, seen_lines, seen_words, seen_line_lengths;

	auto helpInformation = getopt(args, std.getopt.config.passThrough, std.getopt.config.bundling, 
		"c|chars|m|bytes", "Show the character/byte count.", &seen_chars, 
		"l|lines","Show the line count.", &seen_lines, 
		"w|words", "Show the word count.", &seen_words, 
		"L|line-length", "Show maximum line lengths.", &seen_line_lengths
	);
	
	if (helpInformation.helpWanted) {
		defaultGetoptPrinter("Show character, line, word counts.", helpInformation.options);
		return 1;
	}

	if (seen_chars || seen_lines || seen_words || seen_line_lengths) {
		show_chars = seen_chars;
		show_lines = seen_lines;
		show_words = seen_words;
		show_line_lengths = seen_line_lengths;
	}

	FileStats*[] files;

	FileStats* fs;
	if (args.length > 1) {
		foreach (file_arg; args[1 .. $]) {
			fs = new FileStats;
			if (file_arg == "-") {
				fs.file = stdin;
			} else {
				fs.file = File(file_arg, "r");
			}
			fs.fname = file_arg;
			files ~= fs;
		}
	} else {
		fs = new FileStats;
		fs.file = stdin;
		fs.fname = "-";
		files ~= fs;
	}

	ulong char_count_total, line_count_total, word_count_total, max_line_length;
	foreach (f; files) {
		f.doCount();
		char_count_total += f.char_count;
		line_count_total += f.line_count;
		word_count_total += f.word_count;
		if (f.max_line_length > max_line_length) {
			max_line_length = f.max_line_length;
		}
		string[] output;
		if (show_lines)
			output ~= to!string(f.line_count);

		if (show_words)
			output ~= to!string(f.word_count);

		if (show_chars)
			output ~= to!string(f.char_count);

		if (show_words)
			output ~= to!string(f.word_count);

		output ~= f.fname;
		writeln(join(output, " "));
	}

	return 0;
}
