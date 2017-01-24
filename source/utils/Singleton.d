module utils.Singleton;

/**
 Template Singleton pour permettre la génération simple de classe Singleton
*/
mixin template Singleton (T) {

    /**
     Returns l'intance du singleton.
     */
    static ref T instance () {
	if (inst is null) inst = new T;
	return inst;
    }
    
protected:

    this () {}    
    static T inst = null;
    
}
