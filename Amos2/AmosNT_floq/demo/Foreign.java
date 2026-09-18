/*****************************************************************************
 * AMOS2
 *
 * Author: 2014 Tore Risch, UDBL
 * $RCSfile: Foreign.java,v $
 * $Revision: 1.2 $ $Date: 2014/01/06 16:26:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Examples of foreign function definitions in Java
 *
 ****************************************************************************/

/***************************************************************************
 * NOTICE:                                                                 *
 * To include the Amos foreign function definitions below in an Amos       *
 * database image 'mydb.dmp' you have to:                                  *
 * 1. Compile the program with the command:                                *
 *      javac -cp "../bin/javaamos.jar" Foreign.java                       *
 * 2. Make a database image 'mydb.dmp' by running the AmosQL script        *
 *      amos2 -O mydbdef.amosql                                            *
 * 3. Run javaamos (Amos under Java) with database image mydb.dmp:         *
 *      javaamos mydb.dmp                                                  *
 *    Test the functions in AmosQL queries:                                *
 *      helloworld();                                                      *
 *      mysqrt(2);                                                         *
 *      mysqrt(0);                                                         *
 *      mysqrt(-1);                                                        *
 *      myabs(-1.22);                                                      *
 *      select x from Number x where myabs(x)=2.3;                         *
 *      jota(1,5);                                                         *
 *      set :b = jota(1,1000000);                                          *
 *      count(:b);                                                         *
 *      jota(5,1);                                                         *
 **************************************************************************/

import callin.*;
import callout.*;

public class Foreign 
{

    /**
     * Must have default constructor:
     */
    public Foreign()
    {
	// Put initializations here...
    }

    /**
     * AmosQL definition:
     *
     *   create function helloworld() -> Charstring
     *     as foreign "JAVA:Foreign/helloWorldF";
     */

    public void helloWorldF(CallContext cxt, Tuple tpl) throws AmosException
    {
	/* Set first result tuple element (position 0): */  
	tpl.setElem(0,"Hello world");

	/* Emit result to Amos II kernel: */
        cxt.emit(tpl);
    }

    /**
     * AmosQL definition:
     *
     *   create function mysqrt(Number x) -> Bag of Real
     *     as foreign "JAVA:Foreign/mysqrtBF";
     *
     *  Returns bag containing  1 or 2 results if x>=0
     */
    public void mysqrtBF(CallContext cxt, Tuple tpl) throws AmosException
    {

	double x;

	x = tpl.getDoubleElem(0);	// Pick up the real argument
	if (x < 0.0) 
	    {
		// Don't return any value if x < 0
	    }
	else if (x==0)
	    {
		// One root if x is zero
		tpl.setElem(1, 0.0);
		cxt.emit(tpl);
	    }
	else
	    {
		// Two roots
		tpl.setElem(1, Math.sqrt(x));
		cxt.emit(tpl);
		tpl.setElem(1, -Math.sqrt(x));
		cxt.emit(tpl);
	    }
    }

    /**
     * myabs(x) is an example of the implementation of a multidirectional
     * foreign function in Java.
     *
     * AmosQL definition:
     *   create function myabs(Number x) -> Number 
     *     as multidirectional ("bf" foreign "JAVA:Foreign/myabsBF")
     *                         ("fb" foreign "JAVA:Foreign/myabsFB");
     */

    public void myabsBF(CallContext cxt, Tuple tpl) throws AmosException
    {

	double x;
     
	x = tpl.getDoubleElem(0); // pick up first argument
	if(x<0) tpl.setElem(1,-x);
	else    tpl.setElem(1,x);
	cxt.emit(tpl);
    }

    public void myabsFB(CallContext cxt, Tuple tpl) throws AmosException 
    {
	// Inverse of abs(x)
	double x;
     
	x = tpl.getDoubleElem(1); // pick up result
	if(x==0.0)
	    {
		tpl.setElem(0,x);
		cxt.emit(tpl);
	    }
	else
	    {
		tpl.setElem(0,x);
		cxt.emit(tpl);
		tpl.setElem(0,-x);
		cxt.emit(tpl);
	    }
    }

    /**
     * AmosQL definition:
     *   create function jota(Number l, Number u) -> Bag of Number 
     *     as foreign "JAVA:Foreign/jotaBBF";
     *
     *  Returns bag containing u-l+1 elements if u>=l
     */

    public void jotaBBF(CallContext cxt, Tuple tpl) throws AmosException
    {

	int low=tpl.getIntElem(0), up=tpl.getIntElem(1), i;

	for(i=low;i<=up;i++)
	    {
		tpl.setElem(2,i); 
		cxt.emit(tpl);
	    }
    }
}


    
