import openclD._;
import core.stdc.stdio;
import core.stdc.stdlib;
import std.format, std.stdio;
import std.datetime, std.conv;


string KernelSource =  q{
    __kernel void vadd (__global const #(T0) * a, __global const #(T0) * b, __global #(T0) * out, unsigned int count) {
	int i = get_global_id (0);    
	if (i < count)							
	    out [i] = a[i] + b[i];    					
    }
};

enum LENGTH = 8 * 1024;

void main() {
    CLContext.instance.init ();

    auto pkern = new PreKernel (KernelSource, "vadd");
    pkern.feed (0, "float");    
    
    auto kern = pkern.compile (CLContext.instance.devices [0]);

    auto dev = CLContext.instance.devices [0];    
    auto a = new Vector!float (dev, LENGTH);
    auto b = new Vector!float (dev, LENGTH);
    auto c = new Vector!float (dev, LENGTH);
    
    foreach (i ; 0 .. LENGTH) {
	a [i] = rand () / cast (float) RAND_MAX;
	b [i] = rand () / cast (float) RAND_MAX;
    }
    
    // Appel du kernel avec dimGrid, dimBlock, args...    
    kern ((LENGTH + dev.blockSize - 1) / dev.blockSize , dev.blockSize, a, b, c, LENGTH);
    
    ulong correct = 0;
    foreach (it ; 0 .. c.length) {
	auto tmp = a [it] + b [it];
	tmp -= c[it];
	if (tmp * tmp < float.epsilon * float.epsilon)
	    correct ++;
	else writefln ("tmp %f h_a %f h_b %f h_c %f \n",tmp, a [it], b [it], c [it]);
    }

    writefln ("C = A+B:  %d out of %d results were correct.\n", correct, LENGTH);    
}
