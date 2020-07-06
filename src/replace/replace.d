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
import std.file : dirEntries, readText, SpanMode, write;
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
        app.add(new Argument("from", "A string to be replaced.").name("origStr"));
        app.add(new Argument("to", "The new string to be written.").name("toStr"));
        app.add(new Argument("in", "Directory in which to search files for the given string.").name("inDir"));
    },
    (ProgramArgs args) {
        try {
            string inDir = args.arg("inDir");
            if (!inDir.matchFirst("~").empty())
                inDir = expandTilde(inDir);
            if (!isValidPath(inDir))
                throw new Exception(inDir ~ " is not a valid pathname");

            string except = args.option("except");

            SpanMode sMode = args.flag("recurse") ? SpanMode.depth : SpanMode.shallow;

            foreach (path; dirEntries(inDir, sMode)) {
                if ((except != "") && (!path.name().matchFirst(except).empty()))
                    continue;

                if (path.isFile()) {
                    string fileContent;
                    try {
                        fileContent = readText(path.name());
                        writeln("Altered ", path.name());
                    } catch (Exception ex) {
                        continue;
                    }
                    string fileToWrite = fileContent.replace(args.arg("origStr"), args.arg("toStr"));
                    path.name().write(fileToWrite);
                }
            }
        } catch (Exception ex) {
            stderr.writeln(APP_NAME, ": ", ex.msg);
            return 1;
        }

        return 0;
    });
}
