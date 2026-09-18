import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


class myFilterThread extends Thread
{
    public void run()
    {
        /* This thread continuously displays the result tuples of the 
           standing query filter1() on standard output */   
	try {
	    Connection conn = new Connection("A");
	    Scan s;
	    Tuple tpl;

	    System.out.println("testing model and validate: \n");
	    s = conn.executeCustom("model_n_validate(first_n(heartbeat(1), 10)," +
				   "#'expected', #'check_equal'," +
				   "#'thres', {'model_n_validate'});",
				   "(:buffersize 1)");
	    while (!s.eos()) {
		tpl = s.getRow();
		System.out.println("<< (" + tpl.getElem(0) +
				   ", " + tpl.getElem(1) +
				   ", " + tpl.getElem(2) +
				   ", " + tpl.getElem(3) + ")");
		s.nextRow();
	    }

	    System.out.println("\ntesting learn and validate: \n");
	    s = conn.executeCustom("learn_n_validate(first_n(heartbeat(1), 20), 4, #'learnfn1'," +
				   "#'validatefn1', #'thres', {'learn_n_validate'});",
				   "(:buffersize 1)");
	    while (!s.eos()) {
		tpl = s.getRow();
		System.out.println("<< (" + tpl.getElem(0) +
				   ", " + tpl.getElem(1) +
				   ", " + tpl.getElem(2) +
				   ", " + tpl.getElem(3) + ")");
		s.nextRow();
	    }

	    conn.disconnect();
        }
	catch (AmosException e) {
	    System.out.println(e.getMessage() + " myFilterThread");
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
	    Connection conn = new Connection("A");

	    Thread.sleep(5000);
            /* Change threshold() after 5 seconds: */
	    System.out.println("set thres('model_n_validate') = -1;");
	    conn.execute("set thres('model_n_validate') = -1;");

	    Thread.sleep(14000);
            /* Change threshold() after 5 seconds: */
	    System.out.println("set thres('learn_n_validate') = 15;");
	    conn.execute("set thres('learn_n_validate') = 15;");
	    Thread.sleep(5000);
	    /* Change threshold() again after 10 seconds: */
	    System.out.println("set thres('learn_n_validate') = 0;");
	    conn.execute("set thres('learn_n_validate') = 0;");

	    conn.disconnect();
        }
	catch (AmosException e) {
	    System.out.println(e.getMessage() + " myControlThread");
	    e.printStackTrace();
	}
	catch (InterruptedException e) {
	    System.out.println(e.getMessage());
	    e.printStackTrace();
	}
    }
}

public class test_validate
{
    public static void main(String args[]) throws AmosException, InterruptedException 
    {
	Connection.initializeClient();


        System.out.println("\nDisplaying result from one continuous query");
        System.out.println("which is updated at run time from client\n");

	Connection conn = new Connection("A");

        conn.execute("load_amosql('model.osql');");
	
        /* Start thread displaying the result of the continuous 
           query filter1(): */
	new myFilterThread().start();

        /* Start thread dynamically changing parameter threshold(): */
	new myControlThread().start();
        Thread.sleep(30000);
        System.exit(0); /* Stop after 15 seconds */
    }
}
