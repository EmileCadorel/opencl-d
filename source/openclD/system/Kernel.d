module openclD.system.Kernel;
import openclD._;
import openclD.system.exception;
import std.conv, std.string;

class Kernel {

    this (string src, string kern) {
	this._device = CLContext.instance.devices [0];
	this._kernName = kern;
	this.initProgram (src);
    }
    
    this (Device device, string src, string kern) {
	this._device = device;
	this._kernName = kern;
	this.initProgram (src);
    }

    void opCall (Args...) (ulong dimGrid, ulong dimBlock, Args args) {
	this.passArguments (args, 0);
	auto globalSize = dimGrid * dimBlock;
	auto err = clEnqueueNDRangeKernel (this._device.commands, this._kernel, 1, null, &globalSize, &dimBlock, 0, null, null);
	CLContext.checkError (err);
    }
    
    void callWithLocalSize (Args ...) (ulong dimGrid, ulong dimBlock, ulong localSize, Args args) {
	this.passArguments (args, 0);
	clSetKernelArg (this._kernel, args.length, localSize, null);
	auto globalSize = dimGrid * dimBlock;
	auto err = clEnqueueNDRangeKernel (this._device.commands, this._kernel, 1, null, &globalSize, &dimBlock, 0, null, null);
	CLContext.checkError (err);	
    }
    
    void join () {
	auto err = clFinish (this._device.commands);
	CLContext.checkError (err);
    }
    
    private void passArguments (First : Passable, Args...) (First first, Args next, uint nb) {
	first.pass (nb, this._kernel);
	passArguments (next, nb + 1);
    }

    private void  passArguments (First, Args ...) (First first, Args next, uint nb) {
	auto err = clSetKernelArg (this._kernel, nb, first.sizeof, &first);
	CLContext.checkError (err);
	passArguments (next, nb + 1);
    }

    private void passArguments () (uint) {}
    
    private void initProgram (string src) {
	auto aux = toCharPtr (src);
	cl_int err;
	this._program = clCreateProgramWithSource (CLContext.instance.context,
						   1,
						   &aux,
						   null,
						   &err);
	CLContext.checkError (err);
	err = clBuildProgram (this._program, 0, null, null, null, null);
	if (err != CL_SUCCESS) {
	    size_t len;
	    char  [2048] buffer;
	    clGetProgramBuildInfo (this._program, this._device.id, CL_PROGRAM_BUILD_LOG, buffer.sizeof, buffer.ptr, &len);
	    throw new CLException (to!string (buffer));
	}

	this._kernel = clCreateKernel (this._program, this._kernName.ptr, &err);
	CLContext.checkError (err);	
    }
    
    private char * toCharPtr (string data) {
	auto cstr = data.toStringz;
	return cstr [0 .. data.length + 1].dup.ptr;
    }
    
    Device device () {
	return this._device;
    }
    
    private cl_program _program;
    private Device _device;    
    private cl_kernel _kernel;
    private string _kernName;
}
