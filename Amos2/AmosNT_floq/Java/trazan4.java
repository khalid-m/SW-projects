import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


class MyThread3 extends Thread
{
    int ind, cnt;
    MyThread3(int m, int cnt)
    {
        this.ind = m;
	this.cnt = cnt;
    }
    public void run()
    {   
        int i;
	System.out.println(">Starting thread "+ind);

	try {Connection con = new Connection("FOO");
	for(i=1;i<=cnt;i++)
	    {
		Tuple argl=new Tuple(1), t;
		Scan s;
		argl.setElem(0,"t"+ind+":"+i);
		//System.out.println(">"+i+".."+ind);
		System.out.println(">>Call #"+i+" to ID in thread #"+ind);
		s = con.callFunction("OBJECT.ID->OBJECT",argl);
		while(!s.eos())
		    {
			t = s.getRow();
			System.out.println("<<Result from call #"+i+
                                           " to ID in thread #"
                                           +ind+": "+t.getElem(0));
			s.nextRow();
		    }
		//System.out.println("Disconnecting .."+ind);
		System.out.println("<Disconnected call #"+i+" in thread #"
				   +ind);
	    }
	con.disconnect();
        }
	catch(AmosException e)
	    {System.out.println(e.getMessage()+" Tread:"+ind);
	    e.printStackTrace();
	    }
	System.out.println("<Ending thread #"+ind);
    }
}

public class trazan4
{
    public static void main(String args[]) throws AmosException 
    {
	Connection.initializeAmos("java.dmp");
        int threads = Integer.parseInt(args[1].trim());
        int loops = Integer.parseInt(args[2].trim());
        System.out.println("Testing multi-treaded client-server calls ...");
        for(int i=1; i<=threads; i++ )
	    {
		Thread t;
                //System.out.println("Initializing thread "+i);
		t = new MyThread3(i,loops);
		t.start();
	    }
    }
}
