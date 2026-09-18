import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


class myAsynchThread extends Thread
{
    int cnt;
    String serv;
    String cq;
    double wait;

    public myAsynchThread(int cnt, String serv, String cq, double wait)
    {
	this.cnt = cnt;
	this.serv = serv;
	this.wait = wait;
        this.cq = cq;
    }

    public void run()
    {
	System.out.println("Starting thread " + cnt);
	try {
	    Connection conn = new Connection(serv);
	    Scan s;
	    Tuple tpl;

	    s = conn.executeCustom(this.cq, "(:buffersize 1)");
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

public class twocq
{
    public static void main(String args[]) throws AmosException
    {
	Connection.initializeClient();

        System.out.println("\nDisplaying result from two continuous queries");
        System.out.println("produced by the same DSMS server\n");

	new myAsynchThread(1, "a", args[0], 0.3).start();
	new myAsynchThread(2, "a", args[1], 1).start();
    }
}
