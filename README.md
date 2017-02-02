Exemple d'un vec_add.

```D

import system.CLContext, system.Kernel;
import data.Vector;

string KernelSource = q{
    __kernel void vadd (__global const float * a, __global const float * b, __global float * out, unsigned int count) {
        int i = get_global_id (0);    
        if (i < count)				
            out [i] = a[i] + b[i];    				
     }
};


enum LENGTH = 8 * 1024;

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
    
    foreach (it ; c) {
        writlen (it);
    }
}


```
