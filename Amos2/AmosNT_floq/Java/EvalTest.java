/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2002, Tore Risch, UDBL
 * $RCSfile: EvalTest.java,v $
 * $Revision: 1.8 $ $Date: 2008/12/14 16:51:10 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Testing callout evaluation
 * ===========================================================================
 * $Log: EvalTest.java,v $
 * Revision 1.8  2008/12/14 16:51:10  torer
 * Using CallContext.connection()
 *
 ****************************************************************************/

import callin.*;
import callout.*;

/**
   Example class.
*/
public class EvalTest {


    /**
       Must have default constructor.
    */
    public EvalTest() {
	// Put initializations here
    }

    /**
       Foreign function.
       Dynamically executes an AMOSQL statement.
       Declare as
       create function jeval(charstring)->object as
       foreign "JAVA:EvalTest/javaEval";

    */
    public void javaEval(CallContext cxt, Tuple tpl) throws AmosException {

	Scan tmpScan;
	Tuple t;

	// Pick up the argument
	String query = tpl.getStringElem(0);

	try 
	    {
		System.out.println("Executing "+query);
		tmpScan = cxt.connection().execute(query);

		while (!tmpScan.eos()) 
		    {
			t = tmpScan.getRow();
			tpl.setElem(1, t.getOidElem(0));
			cxt.emit(tpl);
			tmpScan.nextRow();
		    }
	    }
	catch(AmosException e)
	    {
		throw(e);
	    }
    }
  

    /**
       Foreign function.
       Calls Java garbage collector
       Declare as
       create function javagc()->boolean as
       foreign "JAVA:EvalTest/javaGC";
    */
    public void javaGC(CallContext cxt, Tuple tpl) throws AmosException {

	System.gc();
    }

    /**
       Foreign function.
       Thows an Amos II error
       Declare as
       create function jerror(charstring)->object as
       foreign "JAVA:EvalTest/jerror";

    */
    public void jerror(CallContext cxt, Tuple tpl) throws AmosException
    {
	String msg = tpl.getStringElem(0);

	throw(new AmosException(msg));
    }

}
