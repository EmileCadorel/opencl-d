import compose.functional;
import std.stdio;
import std.algorithm;
import std.functional;

void main() {

    alias un = binaryFun!"a < b ? a : ";
    static assert (un (int.init, true));
    
    static if (_ctfeMatchUnary ("a &", "a")) {
	static assert (false);
    }

    writeln (all!"a & 1"([1, 3]));
    
}
