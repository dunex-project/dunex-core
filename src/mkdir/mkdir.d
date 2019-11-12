/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	mkdir: Make a directory.

	Author(s): chaomodus
 */

import std.stdio;
import std.getopt;
import std.file;
import std.conv;
import std.algorithm.searching;

uint mode = 0;
bool havemode = false;
bool parents = false;
string directory;

void getMode(string option, string argument) {
	// we can make this more elaborate mode parsing later
	if (argument[0] == '0') {
		havemode = true;
		mode = parse!uint(argument, 8);
	}
}

int main(string[] args) {

	auto helpInformation = getopt(args, std.getopt.config.passThrough,
			"m|mode", "Specify the octal mode of the directory to create.", &getMode, 
			"p|parents", "Create the parents of the target directory (if necessary).", &parents
	);

	if (args.length == 2) {
		directory = args[1];
	}
	if (helpInformation.helpWanted || !directory) {
		defaultGetoptPrinter("Make a directory.", helpInformation.options);
		return 1;
	} else {
		try {
			if (parents) {
				directory.mkdirRecurse;
			} else {
				directory.mkdir;
			}
		} catch (FileException e) {
			writeln("Error making directory: ", e.msg);
			return 2;
		}
	}
	return 0;
}
