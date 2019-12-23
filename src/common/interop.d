module common.interop;
import core.stdc.stdio;
import core.stdc.errno;
import core.stdc.string;
import std.string;

/**
    Turns an stdc error to an exception, if result >= 0 then the result will be returned instead

    Use via UFCS
*/
int throwStdcErr(int result) {
    if (result < 0) throw new Exception(cast(string)errno().strerror().fromStringz);
    return result;
}