/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	sync: call sync system call to flush buffers to disk
	Author(s): chaomodus
*/

import core.sys.posix.unistd : sync;

int main() {
	sync();
	return 0;
}
