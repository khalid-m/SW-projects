import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


class myAsynchThread extends Thread
{
    int cnt;
    String serv;
    String query;

    public myAsynchThread(int cnt, String serv, String query)
    {
	this.cnt = cnt;
	this.serv = serv;
	this.query = query;
    }

    public void run()
    {
	System.out.println("Starting thread " + cnt);
	try {
	    Connection conn = new Connection(serv);
	    Scan s;
	    Tuple tpl;

	    s = conn.executeCustom(query, "(:buffersize 1)");

	    while (!s.eos()) {
		tpl = s.getRow();
		System.out.println("<< " + cnt + ": " + tpl.getElem(0));
		s.nextRow();
	    }

	    conn.disconnect();
        }
	catch (AmosException e) {
	    System.out.println(e.getMessage() + " myAsynchThread");
	    e.printStackTrace();
	}
	System.out.println("Ending thread " + cnt);
    }
}

public class test_block
{
    public static void main(String args[]) throws AmosException
    {
	Connection.initializeClient();

        System.out.println("\nDisplaying result from two continuous queries");
        System.out.println("produced by the same DSMS server\n");

	new myAsynchThread(1, "a", "hagglunds();").start();
	new myAsynchThread(2, "a", "volvo();").start();
    }
}
