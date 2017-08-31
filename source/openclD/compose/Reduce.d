module openclD.compose.Reduce;
import std.string, std.stdio, std.conv;
import openclD._;
import std.functional;
import std.math;

immutable string reduceBody = q{
    {
	unsigned int t = get_local_id (0), start = 2 * get_group_id (0) * get_local_size (0);
	if (start + t < count)
	    partialSum [t] = in_a [start + t];
	else partialSum [t] = 0;
	
	if (start + get_local_size (0)  < count)
	    partialSum [get_local_size (0) + t] = in_a [start + get_local_size (0) + t];
	else partialSum [get_local_size (0) + t] = 0;

	for (unsigned int stride = get_local_size (0); stride >= 1; stride >>= 1) {
	    barrier (CLK_LOCAL_MEM_FENCE);
	    if (t < stride) 
		partialSum [t] = %s;
	}

	if (t == 0) 
	    out_b [get_group_id (0)] = partialSum [0];
    }
};

class Reduce (string op) : Skeleton {

    static T opCall (T) (T [] a) {
	if (!CLContext.instance.isInit) {
	    CLContext.instance.init ();
	}

	auto device = CLContext.instance.devices [0];
	auto in_a = new Vector!T (device, a);
	
	auto kern = createKernel!(T, T.stringof) (device);
	return launchKern (device, kern, in_a);
    }

    static T opCall (T) (Vector!T a) {
	auto device = CLContext.instance.devices [0];	
	auto kern = createKernel!(T, T.stringof) (device);
	return launchKern (device, kern, a);
    }

    
    private {
	static Kernel createKernel (T, string type) (Device device) {
	    auto it  = (type ~ op) in __reduces__;
	    if (it !is null) return *it;
	    immutable auto code = generateProto !(type) ~ generateBody !(toIndexable !("", op));
	    auto kern = new Kernel (device, code, "reduce");
	    __reduces__ [type ~ op] = kern;
	    return kern;
	}

	static T launchKern (T) (Device device, Kernel kern, Vector!T a) {
	    if (a.length <= device.blockSize) {
		auto b = new Vector!T (device, 1);
		kern.callWithLocalSize (1, a.length, 2 * a.length * T.sizeof, a, b, a.length);
		return b[0];
	    } else {
		auto length = a.length;
		auto local = device.blockSize;
		auto global = (a.length + device.blockSize - 1) / device.blockSize;
		while (global != 1) { // TODO verifier que global ne depasse pas.
		    auto b = new Vector!T (device, global);
		    kern.callWithLocalSize (global, local, local * 2 * T.sizeof, a, b, a.length);
		    a = b;
		    local = device.blockSize;
		    global = (a.length + device.blockSize - 1) / device.blockSize;
		}

		auto b = new Vector!T (device, 1);
		kern.callWithLocalSize (1, local, 2 * local * T.sizeof, a, b, a.length);
		return b[0];
	    }
	}
	
	static string generateProto (string type) () {
	    return format ("__kernel void reduce (__global %s * in_a, __global %s * out_b, const unsigned long count, __local %s * partialSum)", type, type, type);
	}

	static string generateBody (string op) () {
	    return format (reduceBody, op);
	}
	
	
	static string toIndexable (string begin, string end) () {
	    static if (end.length == 0) {
		return begin;
	    } else if (end[0] == 'a') {
		return toIndexable !(begin ~ "partialSum [t]", end [1 .. $]);
	    } else if (end[0] == 'b') {
		return toIndexable !(begin ~ "partialSum [stride + t]", end [1 .. $]);
	    } else return toIndexable !(begin ~ end[0], end [1 .. $]);
	}

	static Kernel [string] __reduces__;
	
    }        
}

