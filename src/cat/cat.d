/*
  cat: Catenate file

   Written by: moon child
 */

import std.stdio;
import std.file;
import std.exception;
import std.algorithm.iteration;
import std.algorithm.mutation;

int main(string[] args) {
	int ret;

	if (args.length > 1) {
		foreach (fname; args[1 .. $]) {
			File fp;
			try {
				fp = File(fname);
			} catch (ErrnoException) {
				import std.stdio;
				writefln("%s: %s: No such file or directory", args[0], fname);
				ret = 1;
				continue;
			}

			fp.byChunk(4096).copy(stdout.lockingBinaryWriter);
		}
	} else {
		stdin.byLine(KeepTerminator.yes).copy(stdout.lockingBinaryWriter);
	}

	return ret;
}
