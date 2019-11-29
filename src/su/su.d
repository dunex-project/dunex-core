/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	su: open shell as an other user (generally root)
	Author(s): Clipsey
*/
import core.sys.posix.termios;
import core.sys.posix.unistd : STDIN_FILENO;

import std.stdio;
import std.string;
import std.conv;
import std.getopt;
import std.format;
import std.process;
import std.array : split;
import core.memory : GC;
import std.file : exists;
import dunex.auth.passwd;
import dunex.auth.shadow;
import dunex.auth.crypt;
import dunex.auth.perms;

/**
	The default PATH for normal user login
*/
enum DEFAULT_LOGIN_PATH = ":/user/ucb:/bin:/user/bin";

/**
	The default PATH for root user login
*/
enum DEFAULT_ROOT_LOGIN_PATH = "/usr/ucb:/bin:/usr/bin:/etc";

/**
	The default value that gets returned in the case that /etc/shells does not exist.
*/
enum DEFAULT_NO_SHELLS_RET_VAL = true;

/**
	Allows setting the default user for su
*/
enum DEFAULT_USER = "root";

/**
	The default shell
*/
enum DEFAULT_SHELL = "deesh";

/**
	Help header format string
*/
enum SU_HEADER_FMT = "Super User
Allows you to run an application as a different user (by default %s)
".format(DEFAULT_USER);

/**
	Version text
*/
enum SU_VERSION = "su from dunex core 1.0";

/*
	Default options
*/

/// Wether to do a fast startup
bool fastStartup = false;

/// Wether to preserve the environment
bool preserveEnvironment = false;

/// Wether the shell should be a login shell
bool loginShell;

/// A command to run
string command;

/// The shell to use
string useShell;

/// Wether to show version info
bool showVersionInfo;

/// Wether to show help text
bool showHelp;

int main(string[] args) {
	try {
		string newUser = DEFAULT_USER;

		auto helpInfo = getopt(args, std.getopt.config.passThrough,
			"l|login", "", &loginShell,
			"c|command", "Pass a single command to the shell", &command,
			"f|fast", "Pass -f to the shell (for csh or tcsh)", &fastStartup,
			"p|preserve-environment", "do not reset environment variables", &preserveEnvironment,
			"s|shell", "run specified shell if /etc/shells allows it", &useShell,
			"v|version", "show version info", &showVersionInfo
		);

		if (helpInfo.helpWanted || showHelp) {
			defaultGetoptPrinter(SU_HEADER_FMT, helpInfo.options);
			return 1;
		}

		if (showVersionInfo) {
			writeln(buildVersionText);
			return 0;
		}

		// Select user via first argument that isn't an option
		if (args.length >= 2) {
			newUser = args[1];
		}


		PasswdEntry pass = getPassword(newUser);
		if (!verifyPassword(pass)) {
			throw new Exception("incorrect password");
		}

		// Automatically use the shell the user prefers
		// If such is specified in their user entry
		// and if the user didn't specify a shell to use
		// Otherwise the default shell will be used
		string shell = pass.shell;
		if (shell.length != 0 && useShell.length == 0) {
			useShell = shell;
		} else if (useShell.length == 0) {
			useShell = DEFAULT_SHELL;
		}

		if (!isShellAllowed(useShell)) {
			throw new Exception("shell %s not allowed".format(useShell));
		}

		// Change identity and environment to match new user
		changeEnv(pass, useShell);
		changeIdentity(pass);
		runShell(useShell, command);

		return 0;
	} catch(Exception ex) {
		stderr.writeln(args[0], ": ", ex.msg);
		return 1;
	}
}

/**
	Builds the version text with capabilities listed
*/
string buildVersionText() {
	return "%s".format(SU_VERSION);
}

/**
	Verifies passwords
*/
bool verifyPassword(ref PasswdEntry expected) {
	string correct = "";

	if (expected.isInShadow()) {
		correct = getShadowPassword(expected.username);
	} else {
		correct = expected.password;
	}

	// The follow prerequisites means that a password check is not needed
	// If the user is already root
	// If the user has no password
	if (getuid() == 0 || correct.length == 0) return true;

	string plain = passwordPrompt();
	string enc = crypt(plain, correct);
	
	// Zero fill and force-free the plaintext password
	foreach(i; 0..plain.length) {
		(cast(ubyte[])plain)[i] = 0;
	}
	GC.free(&plain);

	// Slow-equal compare the password hashes
	return sloweq(enc, correct);
}

/**
	Executes a shell
*/
void runShell(string shell, string command) {
	string[] args;
	if (loginShell) args ~= "-l";
	if (fastStartup) args ~= "-f";
	if (command.length != 0) args ~= ["-c", command];
	auto pid = spawnProcess([shell] ~ args);
	wait(pid);
}

/**
	Changes the environment settings
*/
void changeEnv(ref PasswdEntry pass, string shell) {
	if (loginShell) {
		string term = environment["TERM"];
		
		// Clear environment
		foreach(env; environment.toAA()) {
			environment.remove(env);
		}
		if (term.length != 0) {
			environment["TERM"] = term;
		}
		environment["HOME"] = pass.homePath;
		environment["SHELL"] = shell;
		environment["USER"] = pass.username;
		environment["LOGNAME"] = pass.username;
		environment["PATH"] = pass.userId == 0 ? 
			DEFAULT_ROOT_LOGIN_PATH : 
			DEFAULT_LOGIN_PATH;
	}

	if (!preserveEnvironment) {
		environment["HOME"] = pass.homePath;
		environment["SHELL"] = pass.homePath;
		if (pass.userId != 0) {
			environment["USER"] = pass.username;
			environment["LOGNAME"] = pass.username;
		}
	}
}

/**
	Change the identity of the user
*/
void changeIdentity(PasswdEntry user) {
	if (setgid(cast(gid_t)user.groupId))
		throw new Exception("cannot set group id");
	
	if (setuid(cast(uid_t)user.userId))
		throw new Exception("cannot set user id");
}

/**
	Slow equality function
*/
bool sloweq(string a, string b) {
	ubyte[] abytes = cast(ubyte[])a;
	ubyte[] bbytes = cast(ubyte[])b;
	uint diff = cast(uint)a.length ^ cast(uint)b.length;
	foreach(i; 0..abytes.length) {
		diff |= cast(uint)(a[i] ^ b[i]);
	}
	return diff == 0;
}

/**
	Reads a password
*/
string passwordPrompt() {
	termios oldt;
	termios newt;

	stdout.write("Password: ");

	tcgetattr(STDIN_FILENO, &oldt);
	tcgetattr(STDIN_FILENO, &newt);
	newt.c_lflag &= ~(ECHO);
	tcsetattr(STDIN_FILENO, TCSANOW, &newt);
	scope(exit) {
		tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
		stdout.write("\n");
	}
	
	// Stips away all the extra whitespace that readln adds.
	// Otherwise hashes would be wrong
	return readln().stripRight();
}

/**
	Parses /etc/shells to try to find if a shell is allowed
*/
bool isShellAllowed(string shell) {
	import std.file : readText;
	
	// Make sure that /etc/shells exists
	if (!exists("/etc/shells")) {
		return DEFAULT_NO_SHELLS_RET_VAL;
	}

	string shellsInfo = readText("/etc/shells");
	foreach(line; shellsInfo.split("\n")) {

		// Skip empty lines
		if (line.strip.length == 0) continue;

		// Skip comments
		if (line.stripLeft()[0] == '#') continue;

		// Match shells
		if (line == shell) return true;
	}
	return false;
}

PasswdEntry getPassword(string user) {
	return getpwnam(user);
}

string getShadowPassword(string user) {
	return getspnam(user).password;
}
