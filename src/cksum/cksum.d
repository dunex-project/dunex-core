/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	cksum: Print the 32bit "posix" CRC and length of specified file.
	Author(s): chaomodus

	This is an implementation i found on the internet. It doesn't seem to match the standard. The standard has
	an implementation, but it requires reverse iterating the data?
	https://www.unix.com/man-page/posix/1posix/cksum/
 */
import std.bitmanip;
import std.digest;
import std.digest.crc;
import std.format;
import std.stdio;

class PosixChecksum {
	static int polynomial = 0x04C11DB7;
	uint residual = 0;

	void put(ubyte[] bytes) {
		foreach (b; bytes) {
			for (int i = 7; i >= 0; i--) {
				int msb = residual & (1 << 31);
				residual <<= 1;
				if (msb != 0) {
					residual = residual ^ polynomial;
				}
				residual ^= b;
			}
		}
	}

	uint hash() {
		return ~residual;
	}
}

int main(string[] args) {
	auto crc = new PosixChecksum();
	ulong length = 0;
	ubyte[64] inp;

	if (args.length >= 2) {
		auto infile = File(args[1], "r");
		while (!infile.eof) {
			auto slice = infile.rawRead(inp);
			if (slice.length) {
				crc.put(slice);
				length += slice.length;
			}
		}

    // The standard requires the length, in little endian, appended to the data
    // using the minimum number of bytes.
    ubyte[8] lengthArray = cast(ubyte[8])nativeToLittleEndian(length);
    // trim length to minimum number of bytes
    size_t lastidx = lengthArray.length - 1;
    foreach_reverse(i, j; lengthArray) {
      if (j == 0) {
	lastidx = i;
      }	else {
	break;
      }
    }
    crc.put(lengthArray[0..lastidx]);
    writeln(format("%u %d %s", crc.hash(), length, args[1]));
  }
  return 0;
}
