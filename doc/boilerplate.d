/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	Bugs:

	Todo:
	* i18n boilerplate

*/

enum AUTHORS = "<username>, ...";
enum VERSION = "0.0.0";
enum PROGRAM = "<program>";
enum SUMMARY = "Summary of program.";

import commandr;

int main(string[] args) {
  auto args = Program(cast(string)PROGRAM, cast(string)VERSION)
    .summary(cast(string)SUMMARY)
    .author(cast(string)AUTHORS)
    // args
    .parse(args);

  return 0;
}
