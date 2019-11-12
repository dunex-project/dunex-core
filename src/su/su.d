/*
	Copyright (c) 2019, DUNEX Contributors
	Use, modification and distribution are subject to the
	Boost Software License, Version 1.0.  (See accompanying file
	COPYING or copy at http://www.boost.org/LICENSE_1_0.txt)

	su: open shell as an other user (generally root)
	Author(s): Clipsey
*/

import core.sys.posix.pwd;
import core.sys.posix.termios;
import core.stdc.errno;
import core.sys.posix.unistd : 
	crypt,
	getuid, 
	getgid, 
	setuid, 
	setgid, 
	STDIN_FILENO;

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
enum SU_VERSION = "su from dcore 1.0";

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
		"v|version", "show version info", &showVersionInfo);

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

		passwd pass = getpasswd(newUser);
		if (!verifyPassword(pass)) {
			throw new Exception("incorrect password");
		}

		// Automatically use the shell the user prefers
		// If such is specified in their user entry
		// and if the user didn't specify a shell to use
		// Otherwise the default shell will be used
		string shell = cast(string)pass.pw_shell.fromStringz;
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
		stderr.writeln("su: ", ex.msg);
		return 1;
	}
}

/**
	Builds the version text with capabilities listed
*/
string buildVersionText() {
	return "%s (shadow_file=%s)".format(SU_VERSION, CAP_HAS_SHADOW);
}

/**
	Verifies passwords
*/
bool verifyPassword(ref passwd expected) {
	string correct = "";

	version(USE_SHADOW) {
		correct = getspasswd(expected);
	} else {
		// Just use the password passed in
		correct = cast(string)expected.pw_passwd.fromStringz;
	}

	// The follow prerequisites means that a password check is not needed
	// If the user is already root
	// If the user has no password
	if (getuid() == 0 || correct.length == 0) return true;

	string plain = passwordPrompt();
	string enc = cast(string)crypt(plain.toStringz, correct.toStringz).fromStringz;
	
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
void changeEnv(ref passwd pass, string shell) {
	if (loginShell) {
		string term = environment["TERM"];
		
		// Clear environment
		foreach(env; environment.toAA()) {
			environment.remove(env);
		}
		if (term.length != 0) {
			environment["TERM"] = term;
		}
		environment["HOME"] = cast(string)pass.pw_dir.fromStringz;
		environment["SHELL"] = shell;
		environment["USER"] = cast(string)pass.pw_name.fromStringz;
		environment["LOGNAME"] = cast(string)pass.pw_name.fromStringz;
		environment["PATH"] = pass.pw_uid == 0 ? 
			DEFAULT_ROOT_LOGIN_PATH : 
			DEFAULT_LOGIN_PATH;
	}

	if (!preserveEnvironment) {
		environment["HOME"] = cast(string)pass.pw_dir.fromStringz;
		environment["SHELL"] = cast(string)pass.pw_dir.fromStringz;
		if (pass.pw_uid != 0) {
			environment["USER"] = cast(string)pass.pw_name.fromStringz;
			environment["LOGNAME"] = cast(string)pass.pw_name.fromStringz;
		}
	}
}

/**
	Change the identity of the user
*/
void changeIdentity(passwd user) {
	if (setgid(user.pw_gid))
		throw new Exception("cannot set group id");
	
	if (setuid(user.pw_uid))
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

version(USE_SHADOW) {
	/**
		Gets the shadow password hash for a user
	*/
	string getspasswd(passwd expected) {
		// Get password from shadow
		spwd* password = getspnam(expected.pw_name);
		endspent();

		if (password is null && errno == EACCES) {
			throw new Exception("access denied (make sure permissions are set to 4755 and that the owner is root)");
		}

		if (password !is null) 
			return cast(string)password.sp_pwdp.fromStringz.idup;
		else
			return cast(string)expected.pw_passwd.fromStringz;
	}
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

/**
	Safely gets the user's passwd entry
*/
passwd getpasswd(string user) {
	// In both case of success and failure, remember to close the entry
	scope(failure) endpwent();
	passwd* pw = getpwnam(user.toStringz);
	endpwent();

	/**
		Convert the contents to D strings

		This allows us to do somewhat safe length checking on them
		At the same time, we duplicate them
	*/
	string name = pw is null ? null : cast(string)pw.pw_name.fromStringz.idup;
	string dir = pw is null ? null : cast(string)pw.pw_dir.fromStringz.idup;
	string pass = pw is null ? null : cast(string)pw.pw_passwd.fromStringz.idup;
	string shell = pw is null ? null : cast(string)pw.pw_shell.fromStringz.idup;

	// Make sure that the user exists and is valid
	if (pw is null || name.length == 0 || dir.length == 0 || pass is null)
		throw new Exception("user %s does not exist".format(user));

	// We're sure that the user exists; get its PID and GID
	gid_t gid = pw.pw_gid;
	uid_t uid = pw.pw_uid;

	/*
		Make a copy of the password info and return that; 
		some systems (eg. Linux) will screw up if we don't.

		If the shell is empty then make sure we substitude it with our own shell (deesh)
	*/
	passwd copy;
	copy.pw_name = cast(char*)name.toStringz;
	copy.pw_passwd = cast(char*)pass.toStringz;
	copy.pw_dir = cast(char*)dir.toStringz;
	copy.pw_shell = shell.length == 0 ? cast(char*)useShell.toStringz : cast(char*)shell.toStringz;
	copy.pw_gid = gid;
	copy.pw_uid = uid;
	return copy;
}