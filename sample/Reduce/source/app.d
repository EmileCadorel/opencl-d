import std.stdio;
import compose.Reduce;
import std.datetime, std.conv, std.math;

//enum LENGTH = exp2(32);

void main() {
    auto LENGTH = to!ulong (pow (3, 16));
    ulong [] a;
    writeln (LENGTH);
    a.length = LENGTH;
    foreach (it ; 0 .. LENGTH) {
	a [it] = 1;
    }

    // Ca marche !!!
    auto b = Reduce!"a + b" (a);
    writeln (b);
    
}
