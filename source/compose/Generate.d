module compose.Generate;
import compose.Skeleton;
import std.string, std.conv;
import data.Vector, system.Device;
import system.Kernel, system.CLContext;
import std.functional;
import std.math;

class Generate (string op, T) : Skeleton {

    static Vector!T opCall (ulong size) {
	if (!CLContext.instance.isInit) {
	    CLContext.init ();
	}
	
	auto device = CLContext.instance.devices[0];
	auto out_a = new Vector!T (device, size);
	auto kern = createKernel !(T.stringof) (device);
	launchKern (device, kern, out_a);
	return out_a;
    }

    private {

	static Kernel createKernel (string type) (Device device) {
	    auto it = (type ~ op) in __generates__;
	    if (it !is null) return *it;
	    
	    // verification que op est un operateur unaire sur 'i'
	    // is est vrai si typeof est un type valide
	    static if (!is (typeof (unaryFun !(op, "i") (T.init))))
		static assert (false, "(" ~ op ~ ") n'est pas un operateur unaire sur 'i'");
	    
	    immutable auto code = generateProto!(type) ~ generateBody!(op);
	    auto kern = new Kernel (device, code, "generate");
	    __generates__ [type ~ op] = kern;
	    return kern;
	}

	// (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK, THREADS_PER_BLOCK
	static void launchKern (T) (Device dev, Kernel kern, ref Vector!T a) {
	    if (a.length <= dev.blockSize) 
		kern (1, a.length, a, a.length);
	    else 
		kern ((a.length + dev.blockSize - 1) / dev.blockSize, dev.blockSize, a, a.length);	    
	}

	static string generateProto (string type) () {
	    return format (q{
		    __kernel void generate (__global %s *a, unsigned long count)
			}, type);
	}
	
	static string generateBody (string op) () {
	    return format ("{\n\t%s;\n\t%s %s%s;\n}",
			   q{int i = get_global_id (0);},
			   q{if (i < count) },
			   q{a[i] = },
			   op);
			   
	}

	static Kernel [string] __generates__;
	
    }    
    
}
