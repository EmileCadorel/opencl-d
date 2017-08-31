module openclD.system.PreKernel;
import openclD._;
import openclD.system.exception;
import std.conv, std.string;

class PreKernel {

    private string _src;

    private string _kern;
    
    this (string src, string kern) {
	this._src = src;
	this._kern = kern;
    }

    void feed (int nb, string type) {
	auto val = "#(T" ~ nb.to!string ~ ")";
	while (true) {
	    auto index = this._src.indexOf (val);
	    if (index != -1) {
		this._src = this._src [0 .. index] ~ type ~ this._src [index + val.length .. $];
	    } else break;
	}
    }

    Kernel compile (Device dev) {
	auto kern = new Kernel (dev, this._src, this._kern);
	return kern;
    }       

}
