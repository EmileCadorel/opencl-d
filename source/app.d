import system.CLContext, system.Kernel;
import data.Vector;
import core.stdc.stdio;
import core.stdc.stdlib;
import std.format, std.stdio;
import std.datetime, std.conv;
import compose.Skeleton, compose.Map;
import std.algorithm;

enum LENGTH = 100;


void main() {
    float [LENGTH] a;
    foreach (it ; 0 .. LENGTH) {
	a [it] = it;
    }
    
    auto b = Map!"2.3 * a" (a);
    foreach (it ; b) {
	writeln (it);
    }
}
