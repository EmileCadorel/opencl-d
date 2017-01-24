import system.CLContext, system.Kernel;
import data.Vector;
import core.stdc.stdio;
import core.stdc.stdlib;
import std.format, std.stdio;
import std.datetime, std.conv;

string KernelSource = 
    "__kernel void vadd (__global const float * a, __global const float * b, __global float * out, unsigned int count) {" 
    "int i = get_global_id (0);"    
    "if (i < count)"							
    "out [i] = a[i] + b[i];    "					
     "}\n";


enum LENGTH = 8 * 1024;
enum TOL = 0.001;

void main() {
    CLContext.instance.init ();
    
    auto kern = new Kernel (CLContext.instance.devices [0],
			      KernelSource,
			      "vadd");
    
    auto a = new Vector!float (CLContext.instance.devices [0], LENGTH);
    auto b = new Vector!float (CLContext.instance.devices [0], LENGTH);
    auto c = new Vector!float (CLContext.instance.devices [0], LENGTH);

    foreach (i ; 0 .. LENGTH) {
	a [i] = rand () / cast (float) RAND_MAX;
	b [i] = rand () / cast (float) RAND_MAX;
    }
    
    // Appel du kernel avec dimGrid, dimBlock, args...    
    kern (1024, 8, a, b, c, LENGTH);
    
    ulong correct = 0;
    foreach (it ; 0 .. c.length) {
	auto tmp = a [it] + b [it];
	tmp -= c[it];
	if (tmp * tmp < TOL * TOL)
	    correct ++;
	else writefln ("tmp %f h_a %f h_b %f h_c %f \n",tmp, a [it], b [it], c [it]);
    }

    writefln ("C = A+B:  %d out of %d results were correct.\n", correct, LENGTH);    
}
