import callin.*;
import callout.*;

/**
   System foreing Java functions
*/
public class AmosLib {


    /**
       Must have default constructor.
    */
    public AmosLib() {
	// Put initializations here
    }

    /**
       Foreign function.
       Calls Java garbage collector
       Declare as
       create function javagc()->boolean as
       foreign "JAVA:AmosLib/javaGC";
    */
    public void javaGC(CallContext cxt, Tuple tpl) throws AmosException {

	System.gc();
    }
}
