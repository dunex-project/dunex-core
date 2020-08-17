/*
	Copyright (c) 2020, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

    replace: replace a string across a directory

	Written by: Marie-Joseph

*/

module app;

import common.cmd;

import std.array : join, replace;
import std.file : dirEntries, DirEntry, isDir, isFile, readText, SpanMode, write;
import std.format : format;
import std.path : expandTilde, globMatch, isValidPath;
import std.regex : matchFirst;
import std.stdio : stderr, writeln;

enum APP_NAME = "replace";
enum APP_DESC = "Replace all occurrences of a given string in all files in a directory with another string.";
enum APP_VERSION = "1.0 (dunex-core)";
enum APP_AUTHORS = ["Marie-Joseph"];
enum APP_LICENSE = import("COPYING");
enum APP_CAP = [APP_NAME];

int main(string[] args) {
    return runApplication(args, (Program app) {
        app.add(new Flag("r", "recurse", "Enables depth-first recursion.").name("recurse").optional);
        app.add(new Option("e", "except", "A regex which, when present in a pathname, will omit that pathname and any descendants.").name("except").optional);
        app.add(new Option("o", "only", "Only replace the string in the given file. The in argument, and the e and r flags are ignored.").name("only").optional);
        app.add(new Argument("from", "A string to be replaced.").name("origStr"));
        app.add(new Argument("to", "The new string to be written.").name("toStr"));
        app.add(new Argument("in", "The directory in which to search files for the given string.").name("inDir").optional);
    },
    (ProgramArgs args) {
        try {
            string inDir = args.option("only").length > 0 ? args.option("only") : args.arg("inDir");
            if (!inDir.matchFirst("~").empty())
                inDir = expandTilde(inDir);
            if (!isValidPath(inDir))
                throw new Exception(inDir ~ " is not a valid pathname");

            string except = args.option("except");

            SpanMode sMode = args.flag("recurse") ? SpanMode.depth : SpanMode.shallow;

            if (isFile!string(inDir) && !isDir!string(inDir)) {
            	remplacer(args.arg("origStr"), args.arg("toStr"), DirEntry(inDir));
            } else {
            	foreach (path; dirEntries(inDir, sMode)) {
	                if ((except != "") && (!path.name().matchFirst(except).empty()))
	                    continue;

	                if (path.isFile()) {
	                    remplacer(args.arg("origStr"), args.arg("toStr"), path);
	                }
	            }
            }
        } catch (Exception ex) {
            stderr.writeln(APP_NAME, ": ", ex.msg);
            return 1;
        }

        return 0;
    });
}

// "replace" is already used in this namespace 🤷️
void remplacer(string from, string to, DirEntry inFile) {
    string fileContent;
    try {
        fileContent = readText(inFile.name());
        writeln("Altered ", inFile.name());
    } catch (Exception ex) {
        return;
    }
    string contentToWrite = fileContent.replace(from, to);
    inFile.name().write(contentToWrite);
}
