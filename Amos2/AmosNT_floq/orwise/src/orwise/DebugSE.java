package orwise;

import callin.*;
import callout.*;

/** Helps debugging. The output this class produces can be turned on and off by typing
 * setTrace("on"); or setTrace("off").
 * @author Simon Zürcher, University of Uppsala
 * @version ?
 */

class DebugSE {
    private static boolean traceflag = false;
    private static String flag;

    public static DebugSE tracer = new DebugSE();

    /** Switches the debugging messages on or off.
     *  Type setTrace("on"); or setTrace("off") in AMOS.
     *  @params String Switch Since this is a foreign function you use it in AMOS only
     */
    public void setTrace(CallContext cxt, Tuple tpl) throws AmosException{
	try{
	    flag = tpl.getStringElem(0);  //method argument
	}
	catch(AmosException e){
	    System.out.println("Amos-Error (reading): "+e);
	}
	if (flag.equalsIgnoreCase("on")) {
	    traceflag = true;
	    cxt.emit(tpl);
	}
	else if (flag.equalsIgnoreCase("off")) {
	    traceflag = false;
	    cxt.emit(tpl);
	}
	else {
	    System.out.println("Valid arguments are 'on' or 'off'");
	}
    }

    /** Prints out a message if the Flag traceflag is set to "true"
     *   @params String message
     */
    public void msg(String message) {
	if (traceflag) {
	    System.out.println(message);
	}
    }
}
