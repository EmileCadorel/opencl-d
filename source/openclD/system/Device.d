module openclD.system.Device;
import openclD.system.CLContext;
import std.array;

class Device {

    this (cl_device_id id) {
	this._id = id;
    }
    void init (cl_context context) {
	cl_int err;	
	this._commands = clCreateCommandQueue (context, this._id, 0, &err);
	CLContext.checkError (err);

	err = clGetDeviceInfo (this._id, CL_DEVICE_MAX_WORK_GROUP_SIZE, size_t.sizeof, &this._gridSize, null);
	CLContext.checkError (err);

	err = clGetDeviceInfo (this._id, CL_DEVICE_MAX_WORK_ITEM_SIZES, this._blockSize.sizeof, this._blockSize.ptr, null);
	CLContext.checkError (err);	
    }
            
    cl_device_id id () {
	return this._id;
    }    

    cl_command_queue commands () {
	return this._commands;
    }
    
    size_t blockSize (ushort i = 0) {
	return this._blockSize [i];
    }

    size_t gridSize () {
	return this._gridSize;
    }    

    private cl_device_id _id;
    private cl_command_queue _commands;
    private size_t [3] _blockSize;
    private size_t _gridSize;
    
}
