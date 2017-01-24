module system.Device;
import system.CLContext;

class Device {

    this (cl_device_id id) {
	this._id = id;
    }

    void init (cl_context context) {
	cl_int err;
	this._commands = clCreateCommandQueue (context, this._id, 0, &err);
	CLContext.checkError (err);
    }
            
    cl_device_id id () {
	return this._id;
    }    

    cl_command_queue commands () {
	return this._commands;
    }
    
    private cl_device_id _id;
    private cl_command_queue _commands;
    
}
