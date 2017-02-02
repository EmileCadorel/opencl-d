import std.stdio;
import compose.Reduce, compose.Generate;
import std.datetime, std.conv, std.math;
import std.parallelism, std.range;
import std.algorithm.iteration : map;

//enum LENGTH = exp2(32);


void stdPi () {
    enum n = 1_000_000;      

    alias getTerm = (int i) {
	return (1.0 / n) / ( 1.0 + (( i - 0.5 ) * (1.0 / n)) * (( i - 0.5 ) * (1.0 / n))) ;
    };
            
    immutable pi = 4.0 * taskPool.reduce!"a + b"(n.iota.map!getTerm);
    
}


void openclPi () {
    immutable kern = q{ (4.0) / ( 1.0 + (( i - 0.5 ) * (1.0 / n)) * (( i - 0.5 ) * (1.0 / n))) };
    
    auto a = Generate!(kern, float) (1_000_000);
    auto b = Reduce!"a + b" (a);       
}

float retOpenclPi () {
    immutable kern = q{ (4.0) / ( 1.0 + (( i - 0.5 ) * (1.0 / n)) * (( i - 0.5 ) * (1.0 / n))) };
    
    auto a = Generate!(kern, float) (1_000_000);
    auto b = Reduce!"a + b" (a);
    return b;
}

void main() {

    auto _pi = retOpenclPi (); // init pour que le test soit juste
    writefln ("Proof : %g ", _pi);
    
    auto r = benchmark ! openclPi (100);
    writeln ("opencl : ", to!Duration (r[0])); // on se rend compte que c'est de la merde
    
    auto r2 = benchmark!stdPi (100);
    writeln ("std : ", to!Duration (r2[0]));
    
}
