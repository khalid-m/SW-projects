/*****************************************************************************
 * AMOS2
 *
 * Author:  2012 Tore Risch, UDBL
 * $RCSfile: JavaClient.java,v $
 * $Revision: 1.1 $ $Date: 2012/11/02 07:12:50 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Demonstration of streamed SCSQ client-server interface
 * ===========================================================================
 * $Log: JavaClient.java,v $
 * Revision 1.1  2012/11/02 07:12:50  torer
 * The dispatch between command and query in client again temporarily
 *
 ****************************************************************************/

import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;

public class JavaClient
{
    public static void main(String args[]) 
	throws AmosException, InterruptedException 
    {try 
	{
	    System.out.println("\nTesting client-server connection");
	    System.out.println("streaming complex data structures\n");
            /* Initialize streaming  client interface */
            Connection.initializeClient(); /* To make client streamed */

	    /* Connect to server named A: */
	    Connection conn = new Connection("A");

	    /* Install two stored functions in server A: */
	    conn.execute("create function fromData(Number n)" +
			 " -> Bag of Vector as stored;");
	    conn.execute("create function toData(Number n)" +
			 " -> Bag of Vector as stored;");

	    /* Populate fromData(n) with bag of complex data structures: */
	    conn.execute("add fromData(1)= {1,2,3};");
	    conn.execute("add fromData(1)= {{{1,functionnamed('plus')}," +
			 "'ab\"c\\'},1,1.345};");
	    conn.execute("add fromData(1)= {typenamed('object'), 2};");
	    conn.execute("create object instances :a;" + 
			 "add fromData(1)={:a};");

	    /* Open remote scan with buffer size 2 on fromData(1): */
	    Tuple argl = new Tuple(1);
	    argl.setElem(0,1); // The tuple (1)

	    Scan s = conn.callFunctionCustom("fromData",argl,
					     "(:buffersize 2)");

	    /* Iterate over the remote scan and copy fromData() to toData(): */
	    while (!s.eos()) 
		{
		    Tuple tpl = s.getRow();
		    conn.addFunction("toData",argl,tpl);
		    s.nextRow();
		}
	    s.close(); // close remote scan

	    /* Iterate over toData() */
	    s = conn.callFunctionCustom("toData",argl,"(:buffersize 3)");
	    int i=0;
	    while (!s.eos()) 
		{
		    Tuple tpl = s.getRow();
		    System.out.println("<<< " + tpl.getElem(0));
		    i++;
		    s.nextRow();
		}

	    if(i!=4)
                {
		    System.out.println("*****************************");
		    System.out.println("ERROR: Not 4 tuples in toData");
		    System.out.println("*****************************");
                }
            else System.out.println("Streamed client OK");

	    conn.disconnect();        
	}
    catch (AmosException e) 
	{
	    System.out.println(e.errstr);
	    e.printStackTrace();
	}
    }
}
