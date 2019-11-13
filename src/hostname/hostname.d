import std.stdio;
import std.file;
import std.getopt;
import std.string;
import std.array;

static import unistd = core.sys.posix.unistd;

enum HOSTNAME_VERSION = "hostname from dcore 1.0\nAuthor(s): Clipsey";

bool useAlias = false;

bool useDomain = false;

bool useFQDN = false;

string file = null;

bool useIPs = false;

bool useShortName = false;

bool useNIS = false;

bool showVersionInfo = false;


int main(string[] args) {
	try {
		auto helpInfo = getopt(args, config.passThrough, config.caseSensitive,
			"a|aliases", "alias names", &useAlias,
			"d|domain", "DNS domain name", &useDomain,
			"f|file", "set host name or NIS domain name from file", &file,
			"i|ip-addresses", "addresses for the host name", &useIPs,
			"s|short", "short host name", &useShortName,
			"y|yp|nis", "NIS/YP domain name", &useNIS,
			"v|version", "print version information", &showVersionInfo
		);

		if (helpInfo.helpWanted) {
			defaultGetoptPrinter("Hostname\nUsage: hostname [options...] [name]", helpInfo.options);
			return 0;
		}

		if (showVersionInfo) {
			writeln(HOSTNAME_VERSION);
			return 0;
		}

		writeln(gethostname());

		return 0;
	} catch (Exception ex) {
		stderr.writeln("hostname: ", ex.msg);
		return 1;
	}
}

string gethostname() {
	string hostnameText = readText("/etc/hostname");
	return hostnameText.stripRight;
}