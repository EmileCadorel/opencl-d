import system.CLContext, system.Kernel;
import data.Vector;
import core.stdc.stdio;
import core.stdc.stdlib;
import std.format, std.stdio;
import std.datetime, std.conv;
import compose.Skeleton, compose.Map;
import std.algorithm;
import std.conv, std.datetime;

enum LENGTH = 100000;
float [LENGTH] a;

void test () {
    auto b = Map!"2.3 * a" (a);    
    auto v = b[0];
}

void main() {
    CLContext.instance.init ();
    foreach (it ; 0 .. LENGTH) {
	a [it] = it;
    }
    
    auto r = benchmark!test (100);
    auto res = to!Duration (r[0]);
    writeln ("time ", res);
    
    /*    foreach (it ; b) {
	writeln (it);
	}*/
}
