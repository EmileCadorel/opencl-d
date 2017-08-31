module openclD.compose.Map;
import std.string, std.stdio, std.conv;
import openclD._;
import std.functional;

class Map (string op) : Skeleton {
   
    static Vector!T opCall (T) (T [] a) {
	
	if (!CLContext.instance.isInit) {
	    CLContext.init ();
	}
	
	auto device = CLContext.instance.devices [0];
	auto in_a = new Vector!T (device, a);
	auto out_b = new Vector!T (device, a.length);
	
	auto kern = createKernel!(T, T.stringof) (device);
	lauchKern (device, kern, in_a, out_b);
	return out_b;
    }
    
    private {

	static Kernel createKernel (T, string type) (Device device) {
	    auto it = (type ~ op) in __maps__;
	    if (it !is null) return *it;

	    // verification que op est un operateur unaire sur 'a'
	    // is est vrai si typeof est un type valide
	    static if (!is (typeof (unaryFun !(op, "a") (T.init))))
		static assert (false, "(" ~ op ~ ") n'est pas un operateur unaire sur 'a'");
	    
	    immutable auto code = generateProto !(type) ~ generateBody !(toIndexable !("", op));
	    auto kern = new Kernel (device, code, "map");	
	    __maps__ [type ~ op] = kern;
	    return kern;
	}
	
	static void lauchKern (T) (Device dev, Kernel kern, ref Vector!T a, ref Vector!T b) {
	    if (a.length <= dev.blockSize) 
		kern (1, a.length, a, b, a.length);
	    else 
		kern ((a.length + dev.blockSize - 1) / dev.blockSize, dev.blockSize, a, b, a.length);	    
	}

	
	static string generateProto (string type) () {
	    return format (q{__kernel void map (__global %s * a, __global %s * b, unsigned long count)}, type, type);
	}	
	
	static string generateBody (string op) (){
	    return format ("{\n\t%s;\n \t%s %s%s;\n}",
			   q{int idx = get_global_id (0)},
			   q{if (idx < count)},
			   q{b [idx] = },
			   op);
	}
	
	static string toIndexable (string begin, string end) () {
	    static if (end.length == 0) {
		return begin;
	    } else if (end [0] == 'a') {
		return toIndexable! (begin ~ end [0] ~ " [idx]", end [1 .. $]);
	    } else return toIndexable !(begin ~ end[0], end [1 .. $]);
	}
	
	static Kernel [string] __maps__;

	
    }
    
}


