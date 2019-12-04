import commandr;
import std.format;
import std.array : join;
import std.stdio : writeln;
import std.file : write;

public import commandr;

/**
    Parses a command and fetches the base information from the module called from.
    Example:

    ```d
        enum APP_NAME = "appname";
        enum APP_VERSION = "1.0";
        enum APP_CAP = ["core"];
        enum APP_DESC = "Description of program";
        enum APP_AUTHORS = ["Clipsey", "chaomodus"];
        enum APP_LICENSE = import("res/LICENSE");

        int main(string[] args) {
            return runApplication(args, 
                (Program app) {
                    // Add arguments
                },
                (ProgramArgs args) {
                    // Handle passed arguments and do stuff
                }
            );
        }
    ```
*/
int runApplication(string mod = __MODULE__)(string[] args, void delegate(Program) argc, int delegate(ProgramArgs) exec) {
    pragma(msg, "Building command structure for %s...".format(mod));
    mixin(q{import %s;}.format(mod));

    static assert(__traits(hasMember, mixin(mod), "APP_NAME"), "APP_NAME not specified");
    static assert(__traits(hasMember, mixin(mod), "APP_VERSION"), "APP_VERSION not specified");
    static assert(__traits(hasMember, mixin(mod), "APP_CAP"), "APP_CAP not specified");
    static assert(__traits(hasMember, mixin(mod), "APP_DESC"), "APP_DESC not specified");
    static assert(__traits(hasMember, mixin(mod), "APP_AUTHORS"), "APP_AUTHORS not specified");
    static assert(__traits(hasMember, mixin(mod), "APP_LICENSE"), "APP_LICENSE not specified");

    // Create base instance
    auto appInstance = new Program(mixin(mod).APP_NAME, mixin(mod).APP_VERSION);
    appInstance.binaryName(mixin(mod).APP_NAME);
    appInstance.authors(mixin(mod).APP_AUTHORS);
    appInstance.summary(mixin(mod).APP_DESC);

    // Add our common flags
    appInstance.add(new Flag(null, "license", "Shows license text"));
    argc(appInstance);

    ProgramArgs argInstance = appInstance.parseArgs(args);
    if (argInstance.hasFlag("version")) {
        string name = appInstance.name;
        string version_ = appInstance.version_;
        string capabilities = mixin(mod).APP_CAP.join(", ");
        string authors = mixin(mod).APP_AUTHORS.join(", ");
        writeln("%s %s (%s)\nWritten by: %s".format(name, version_, capabilities, authors));
        return 0;
    }

    if (argInstance.hasFlag("license")) {
        writeln(mixin(mod).APP_LICENSE);
        return 0;
    }

    if (argInstance.hasFlag("help")) {
        HelpOutput hopt;
        hopt.colors = true;
        appInstance.printHelp(hopt);
        return 0;
    }

    return exec(argInstance);
}