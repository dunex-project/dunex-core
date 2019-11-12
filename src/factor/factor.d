/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	factor: Factor specified numbers into their prime factors.
	Author(s): chaomodus
*/

import std.array;
import std.algorithm.iteration : map;
import std.conv;
import std.math;
import std.stdio;

ulong[] primes;

ulong[] sieve(ulong maximum) {
	bool[] isPrime;
	isPrime.length = maximum;
	for (ulong i = 0; i < maximum; i++) {
		isPrime[i] = true;
	}

	for (ulong idx = 2; idx <= to!ulong(floor(sqrt(to!float((maximum))))) + 1; idx++) {
		if (!isPrime[idx])
			continue;

		for (ulong update = (idx + idx); update < maximum; update += idx) {
			isPrime[update] = false;
		}
	}

	ulong[] output;

	for (ulong i = 2; i < maximum; i++) {
		if (isPrime[i])
			output ~= i;
	}
	return output;

}

ulong[] trial_divs(ulong nr) {
	ulong[] factors;
	ulong worknr = nr;
	foreach (prime; primes) {
		if ((prime * prime) > worknr)
			break;

		while ((worknr % prime) == 0) {
			factors ~= prime;
			worknr = worknr / prime;
		}
	}
	if (worknr > 1)
		factors ~= worknr;

	return factors;
}

int main(string[] args) {
	ulong[] targets;
	ulong maximum;
	foreach (arg; args[1 .. $]) {
		ulong argl = to!ulong(arg);
		targets ~= argl;
		if (argl > maximum)
			maximum = argl;
	}
	primes = sieve(maximum);

	foreach (target; targets) {
		writeln(target, ": ", join(map!(a => to!string(a))(trial_divs(target)), " "));
	}
	return 0;
}
