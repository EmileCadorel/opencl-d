module compose.Map;
import std.string, std.stdio, std.conv;
import compose.Skeleton;
import data.Vector, system.Device;
import system.Kernel, system.CLContext;
import compose.functional;

class Map (string op) : Skeleton {
   
    static Vector!T opCall (T) (T [] a) {
	if (!CLContext.instance.isInit) {
	    CLContext.instance.init ();
	}
	
	auto device = CLContext.instance.devices [0];
	auto in_a = new Vector!T (device, a);
	auto out_b = new Vector!T (device, a.length);
	
	auto kern = createKernel (T.stringof, device);
	lauchKern (device, kern, in_a, out_b);
	return out_b;
    }
    
    private {

	static Kernel createKernel (string type, Device device) {
	    auto it = type in __maps__;
	    if (it !is null) return *it;
	    auto code = generateProto (type) ~ generateBody (toIndexable !("", op));
	    auto kern = new Kernel (device, code, "map");	
	    __maps__ [type] = kern;
	    return kern;
	}
	
	static void lauchKern (T) (Device dev, Kernel kern, ref Vector!T a, ref Vector!T b) {
	    kern (dev.gridSize, dev.blockSize, a, b, a.length);
	}

	
	static string generateProto (string type) {
	    return format ("__kernel void map (__global %s * a, __global %s * b, unsigned long count)", type, type);
	}	
	
	static string generateBody (string op) {
	    return format ("{\n\t%s;\n \t%s %s%s;\n}",
			   "int idx = get_global_id (0)",
			   "if (idx < count)",
			   "b [idx] = ",
			   op);
	}
	
	static string toIndexable (string begin, string end) () {
	    // TODO verifier que l'operateur est correct
	    /*	    static if (!end._ctfeMatchUnary ("a"))
	     static assert (false, end ~ " n'est pas une operateur unaire");*/
	    static if (end.length == 0) {
		static if (begin.indexOf ('a') == -1)
		    static assert (false, "a necessaire dans le lambda");
		return begin;
	    } else if (end [0] == 'a') {
		return toIndexable! (begin ~ end [0] ~ " [idx]", end [1 .. $]);
	    } else return toIndexable !(begin ~ end[0], end [1 .. $]);
	}
	
	static Kernel [string] __maps__;

	
    }
    
}


