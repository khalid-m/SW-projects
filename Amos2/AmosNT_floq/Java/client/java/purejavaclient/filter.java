package udbl.amos.purejavaclient;

import java.io.IOException;


class FilterThread extends Thread
{
    public void run()
    {
        /* This thread continuously displays the result tuples of the 
           standing query filter1() on standard output */   
	try {
	    Connection conn = new Connection("localhost","A");
	    Scan s;
	    Tuple tpl;

	    s = conn.executeCustom("filter1();", "(:buffersize 1)");

	    while (!s.eos()) {
		tpl = s.getRow();
		System.out.println("<< " + tpl.getElem(0));
		s.nextRow();
	    }

	    conn.disconnect();
        }
	catch (AmosException e) {
	    System.out.println(e.getMessage() + " myFilterThread");
	    e.printStackTrace();
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
    }
}

class myControlThread extends Thread
{
    public void run()
    { 
        /* This thread simulates user changes to parameter threshold()
           influencing the continuous query filter1() asyncronously running
           in thread muFilterThread */  
	try {
	    Connection conn = new Connection("localhost","A");

	    Thread.sleep(5000);
            /* Change threshold() after 5 seconds: */
	    System.out.println("set threshold() = 0;");
	    conn.execute("set threshold() = 0;");
	    Thread.sleep(5000);
	    /* Change threshold() again after 10 seconds: */
	    System.out.println("set threshold() = 0.5;");
	    conn.execute("set threshold() = 0.5;");

	    conn.disconnect();
        }
	catch (AmosException e) {
	    System.out.println(e.getMessage() + " myControlThread");
	    e.printStackTrace();
	}
	catch (InterruptedException e) {
	    System.out.println(e.getMessage());
	    e.printStackTrace();
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	} catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
    }
}

public class filter
{
    public static void main(String args[]) throws Exception 
    {
	//Connection.initializeClient();


        System.out.println("\nDisplaying result from one continuous query");
        System.out.println("which is updated at run time from client\n");

	Connection conn = new Connection("localhost","A");

        /* Install filter functions in server A: */
	conn.execute("create function threshold() -> number as stored;");
	conn.execute("set threshold() = 0.1;");
	conn.execute("create function filter1() -> bag of number " +
		     "as for each number x where x in cos(heartbeatbag(1)) "+
		     "if x > threshold() then return x;");

        /* Start thread displaying the result of the continuous 
           query filter1(): */
	new FilterThread().start();

        /* Start thread dynamically changing parameter threshold(): */
	//new myControlThread().start();
        Thread.sleep(15000);
        System.exit(0); /* Stop after 15 seconds */
    }
}
