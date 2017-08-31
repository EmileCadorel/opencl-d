module openclD.system.CLContext;
public import derelict.opencl.cl;
import openclD.system.Device;
import openclD.utils.Singleton;
import openclD.system.exception;
import std.conv;


class CLContext {

    private enum DEVICE = CL_DEVICE_TYPE_DEFAULT;

    static void init () {
	CLContext.instance._init ();
    }
    
    private void _init () {	
	DerelictCL.load ();
	this.initDevices ();
	this.initContext ();
	this._isInit = true;
    }
    
    cl_context context () {
	return this._context;
    }

    static void checkError (cl_int err) {
	if (err != CL_SUCCESS) {
	    throw new CLException (err);
	}
    }    

    bool isInit () {
	return this._isInit;
    }
    
    Device [] devices () {
	if (!this._isInit) this._init ();
	return this._devices;
    }
    
    private void initDevices () {
	auto err = clGetPlatformIDs (0, null, &this._nbPlatforms);
	checkError (err);
	if (this._nbPlatforms == 0) throw new CLException ("No device");
	this._platforms.length = this._nbPlatforms;
	err =  clGetPlatformIDs (this._nbPlatforms, this._platforms.ptr, null);
	checkError (err);

	foreach (it ; 0 .. this._nbPlatforms) {
	    cl_device_id id;
	    err = clGetDeviceIDs (this._platforms [it], DEVICE, 1, &id, null);
	    if (err == CL_SUCCESS) {
		this._devices ~= [new Device (id)];
		this._deviceIds ~= [id];
	    }
	}
	
	if (this._devices.length == 0) checkError (err);		
    }

    private void initContext () {
	cl_int err;
	this._context = clCreateContext (null,
					 to!uint (this._deviceIds.length),
					 this._deviceIds.ptr,
					 null,
					 null,
					 &err);
	
	checkError (err);
	foreach (it ; this._devices) {
	    it.init (this._context);
	}
    }
    
    private cl_context _context;
    private Device [] _devices;
    private cl_device_id [] _deviceIds;
    private cl_platform_id [] _platforms;    
    private cl_uint _nbPlatforms;
    private bool _isInit = false;
    
    mixin Singleton!CLContext;
    

}
