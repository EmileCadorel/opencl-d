module openclD.data.Vector;
import openclD.system.CLContext;
import openclD.system.Device;
import openclD.data.Passable;

class Vector (T) : Passable {

    T[] alloc (T) (ulong size) {
	import core.memory;
	return (cast (T*) GC.malloc (size * T.sizeof)) [0 .. size];
    }
    
    this (ulong size) {
	this._device = CLContext.instance.devices [0];
	this._h_datas = alloc!T (size);
    }

    this (T [] data) {
	this._device = CLContext.instance.devices [0];
	this._h_datas = data;
    }
    
    this (Device device, ulong size) {
	this._device = device;
	this._h_datas = alloc!T (size);
    }

    this (Device device, T [] data) {
	this._device = device;
	this._h_datas = data;
    }

    ref T[] local () {
	if (!this._isLocal) {
	    this.copyToLocal ();
	}
	return this._h_datas;
    }
    
    ref T opIndex (ulong index) {
	if (!this._isLocal) {
	    this.copyToLocal ();
	}	
	return this._h_datas [index];
    }

    void opIndexAssign (T other, ulong index) {
	if (!this._isLocal) {
	    this.copyToLocal ();
	}	
	this._h_datas [index] = other;
    }

    const (ulong) length () {
	return this._h_datas.length;
    }

    void length (ulong length) {
	this._h_datas.length = length;
	if (this._d_datas) 
	    clReleaseMemObject (this._d_datas);
	allocDeviceData ();
    }
    
    override void pass (uint nb, cl_kernel kern) {
	if (this._isLocal) this.copyToDevice ();
	auto err = clSetKernelArg (kern, nb, cl_mem.sizeof, &this._d_datas);
	CLContext.checkError (err);
    }
    

    void copyToLocal () {
	auto err = clEnqueueReadBuffer (this._device.commands,
					this._d_datas,
					this._isBlocking ? CL_TRUE : CL_FALSE,
					0,
					T.sizeof * this._h_datas.length,
					this._h_datas.ptr,
					0,
					null,
					null);
	
	CLContext.checkError (err);
	this._isLocal = true;
    }


    private void copyToDevice () {
	if (this._d_datas is null) this.allocDeviceData ();	
	cl_int err = clEnqueueWriteBuffer (this._device.commands,
			      this._d_datas,
			      this._isBlocking ? CL_TRUE : CL_FALSE,
			      0,
			      T.sizeof * this._h_datas.length,
			      this._h_datas.ptr,
			      0,
			      null,
			      null);
	
	CLContext.checkError (err);
	this._isLocal = false;
    }

    int opApply (scope int delegate (ref T) dg) {
	if (!this._isLocal) this.copyToLocal ();
	auto result = 0;
	for (int i = 0; i < this._h_datas.length; i++) {
	    result = dg (this._h_datas [i]);
	    if (result) break;
	}
	return result;
    }

    
    private void allocDeviceData () {
	cl_int err;
	this._d_datas = clCreateBuffer (CLContext.instance.context,
					this._mode,
					T.sizeof * this._h_datas.length,
					null,
					&err);
	
	CLContext.checkError (err);
    }

    override string toString () {
	import std.conv;
	if (!this._isLocal) this.copyToLocal ();
	return this._h_datas.to!string;
    }
    
    
    ~this () {
	if (this._d_datas) {
	    clReleaseMemObject (this._d_datas);	    
	}
    }


    private bool _isLocal = true;
    private T [] _h_datas;
    private cl_mem _d_datas = null;
    private Device _device;
    private cl_mem_flags _mode = CL_MEM_READ_ONLY;
    private bool _isBlocking = true;
    
}
