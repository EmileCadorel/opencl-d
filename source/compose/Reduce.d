module compose.Reduce;
import std.string, std.stdio, std.conv;
import compose.Skeleton;
import data.Vector, system.Device;
import system.Kernel, system.CLContext;
import std.functional;
import std.math;

/*
__global__ void total(float * input, float * output, int len) {
  __shared__ float partialSum[2 * 1024];
  unsigned int t = threadIdx.x, start = 2 * blockIdx.x * blockDim.x;
    
    if (start + t < len)
       partialSum[t] = input[start + t];
    else
      partialSum[t] = 0;
    if (start + blockDim.x + t < len)
      partialSum[blockDim.x + t] = input[start + blockDim.x + t];
    else
       partialSum[blockDim.x + t] = 0;

    for (unsigned int stride = blockDim.x; stride >= 1; stride >>= 1) {
       __syncthreads();
       if (t < stride)
          partialSum[t] += partialSum[t+stride];
    }

    if (t == 0)
       output[blockIdx.x] = partialSum[0];
}
*/

class Reduce (string op) : Skeleton {

    static T opCall (T) (T [] a) {
	if (!CLContext.instance.isInit) {
	    CLContext.instance.init ();
	}

	auto device = CLContext.instance.devices [0];
	auto in_a = new Vector!T (device, a);
	auto out_b = new Vector!T (device, Math.log2 (a.length));
	
	auto kern = createKernel (T.stringof, device);
	//	lauchKern (device, kern, in_a, out_b);
	return out_b;
    }

    private {
	static Kernel createKernel (string type, Device device) {
	    auto it  = (type ~ op) in __reduces__;
	    if (it !is null) return *it;
	    auto code = generateProto (type) ~ generateBody (toIndexable !("", op));
	    auto kern = new Kernel (device, code, "map");
	    __reduces__ [type ~ op] = kern;
	    return kern;
	}

	static void launchKern (T) (Device dev, Kernel kern, ref Vector!T a, ref Vector!T b) {
	    kern (dev.gridSize, dev.blockSize, a, b, a.length);
	}
	
	static string toIndexable (string begin, string end) () {
	    // TODO
	}		
    }        
}

