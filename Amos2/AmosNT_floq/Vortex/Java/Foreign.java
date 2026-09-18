/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998-2006 Tore Risch, UDBL
 * $RCSfile: Foreign.java,v $
 * $Revision: 1.14 $ $Date: 2012/03/02 15:24:39 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Demonstration and test of foreign functions in Java
 * ===========================================================================
 * $Log: Foreign.java,v $
 * Revision 1.14  2012/03/02 15:24:39  torer
 * Added hello world function
 *
 * Revision 1.13  2010/09/11 03:07:40  torer
 * Byte buffer interface for JDBC strings
 *
 * Revision 1.12  2010/09/09 19:58:13  torer
 * bigstring2 was incorrect
 *
 * Revision 1.11  2010/09/09 14:31:19  torer
 * Test and demo of addStringElem
 *
 * Revision 1.10  2009/01/06 14:54:40  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.9  2006/02/15 13:18:19  torer
 * Demonstration of opaque objects in Java: jear(Date)->Integer in Java
 *
 ****************************************************************************/

import callin.*;
import callout.*;

/**
 * Example class for testing the callout-interface to foreign Java-functions.
 */
public class Foreign 
{

    /**
     * Must have default constructor.
     */
    public Foreign()
    {
	// Put initializations here...
    }

    /**
     * The foreign function.
     * After declaring sqrt() as follows in AMOS2:
     *
     *   create function javaSqrt(real) -> real as
     *   as foreign "JAVA:Foreign/sqrtbf";
     *
     * AMOS2 calls this method when the user executes a call to jsqrt();
     */
    public void sqrtbf(CallContext cxt, Tuple tpl) throws AmosException
    {

	double x;

	x = tpl.getDoubleElem(0);	// Pick up the argument
	if (x < 0.0) 
	    {
		// Don't return any value if sqrt() is undefined.
	    }
	else if (Math.abs(x) < 1.0E-7)
	    {
		// One root
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
       The following is an example of the implementation of a multidirectional
       foreign function in Java. 
       It is callable after the following AMOSQL definition:
       create function myabs(number n)-> number a 
       as multidirectional ("bf" foreign "JAVA:Foreign/absbf")
       ("fb" foreign "JAVA:Foreign/absfb");
    */

    public void absbf(CallContext cxt, Tuple tpl) throws AmosException
    {

	double x;
     
	x = tpl.getDoubleElem(0); // pick up first argument
	if(x<0) tpl.setElem(1,-x);
	else    tpl.setElem(1,x);
	cxt.emit(tpl);
    }

    public void absfb(CallContext cxt, Tuple tpl) throws AmosException 
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

    public void helloWorld(CallContext cxt, Tuple tpl) throws AmosException
    {
        System.out.println("Hello world");
    }

    public void bigstring(CallContext cxt, Tuple tpl) throws AmosException
    {
	int sz = tpl.getIntElem(0),i;
        byte [] b =new byte[sz];

        for(i=0;i<sz;i++) b[i] = '!';
        tpl.setElem(1,new String(b, 0, 0, sz));
        cxt.emit(tpl);
    }

    public void bigstring2(CallContext cxt, Tuple tpl) throws AmosException
    {
	int buffsize = tpl.getIntElem(0);
        int sz = tpl.getIntElem(1);
        int i;
        byte [] b =new byte[buffsize];

        for(i=0;i<buffsize;i++) b[i] = '!';
        tpl.setElem(2,"");  // initialize sequence
        for(i=0;i<=buffsize-sz;i=i+sz)
	    {
                tpl.addElem(2, new String(b, 0, i, sz)); // add string section
            }
        if(i<buffsize) 
	    tpl.addElem(2,new String(b, 0, i, buffsize-i));// add final section
        cxt.emit(tpl);
    }

    public void bigbytes(CallContext cxt, Tuple tpl) throws AmosException
    {
	int buffsize = tpl.getIntElem(0);
        int sz = tpl.getIntElem(1);
        int i;
        byte [] b =new byte[buffsize];

        for(i=0;i<buffsize;i++) b[i] = '!';
        tpl.setElem(2,"");  // initialize sequence
        for(i=0;i<sz;i++)
	    {
                tpl.addElem(2, b, buffsize); // add string section
            }
        cxt.emit(tpl);
    }

    public void jotabf(CallContext cxt, Tuple tpl) throws AmosException
    {

	int low=tpl.getIntElem(0), up=tpl.getIntElem(1), i;

	for(i=low;i<=up;i++)
	    {
		tpl.setElem(2,i);
		cxt.emit(tpl);
	    }
    }
    public void buggy(CallContext cxt, Tuple tpl) throws AmosException
    {
        double i=1.9, j=i/0.0;
    }
    /* To crash the JVM do this:
       create function buggy()-> Boolean as
       foreign "JAVA:Foreign/buggy";
       buggy(); */

    public void jearbf(CallContext cxt, Tuple tpl) throws AmosException
    { /* Get the year out of a date. 
         Demos passing of opaque objects as type Oid. 
         create function jear(Date d)->Integer 
	 as foreign "JAVA:Foreign/jearbf";
         Test: jear(date(now()));
      */
        Scan s;
        Tuple arg = new Tuple(1), res;
        Connection theConnection = new Connection("");
        
        arg.setElem(0,tpl.getElem(0));
        s = theConnection.callFunction("YEAR",arg,1);
        res = s.getRow();
        if(res == null) return;
        tpl.setElem(1,res.getIntElem(0));
        cxt.emit(tpl);
    }

    public void backgroundbf(CallContext cxt, Tuple tpl) throws AmosException
    { /* Do something not calling Amos II in the background 
         and signal when ready.
	 create function background(Integer w)-> Real
	 as foreign "JAVA:Foreign/backgroundbf"; */
        int w = tpl.getIntElem(0);
        Oid bg = cxt.getBG();

        tpl.setElem(1,w);
        System.out.println("About to sleep "+w);
	cxt.enterBG(bg);
        /* WARNING! No Amos II primitive can be called here! */
        try{Thread.sleep(w*1000);} catch(Throwable e)
          {System.out.println("sleep failed");};
        System.out.println("Woke up");
        cxt.leaveBG(bg);
        cxt.emit(tpl);               
    }
}


    
