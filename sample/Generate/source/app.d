import std.stdio;
import system.CLContext;
import compose.Generate;
import std.datetime, std.conv;

enum LENGTH = 10000;

void test () {
    auto a = Generate!("i * 4.1", float) (LENGTH);
    auto b = a[0]; // On recupere les données sur le cpu.   
}

void main() {
    CLContext.init (); // Inutile normalement mais pour un bench plus juste
    
    auto r = benchmark!test (100);
    auto res = to!Duration (r [0]);
    writeln ("time ", res);
}
