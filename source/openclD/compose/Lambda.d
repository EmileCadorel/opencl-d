module openclD.compose.Lambda;
import std.traits;

template Lambda (alias Fun, string fun) {

    static string toString () {
	return fun;
    }
    
    static auto call (T ...) (T values) {
	static if (is (ReturnType!(Fun) == void)) {
	    Fun (values);
	} else {
	    return Fun (values);
	}
    }    

}

