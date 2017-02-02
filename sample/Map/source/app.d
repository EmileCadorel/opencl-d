import std.stdio, system.CLContext;
import compose.Map;
import std.datetime, std.conv;

enum LENGTH = 100000;
float [LENGTH] a;

void test () {
    auto b = Map!("a * 4.3") (a); // Le map est capable d'init opencl
    auto v = b[0]; // pour rappatrier les données;
}

void main() {
    CLContext.instance.init (); // On ne compte pas l'init dans le bench
    foreach (it ; 0 .. LENGTH) {
	a [it] = it;
    }
    auto r = benchmark!test (100); 
    auto res = to!Duration (r[0]);
    writeln ("time ", res);
    
}
