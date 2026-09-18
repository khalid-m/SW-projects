import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


class MyLocalThread extends Thread
{
    int ind, cnt;
    String fname;
    MyLocalThread(int m, int cnt, String fname)
    {
        this.ind = m;
	this.cnt = cnt;
        this.fname = fname;
    }
    public void run()
    {   
        int i;
	//System.out.println(">Thread "+ind);
	try {	    
	    Tuple argl=new Tuple(1), t;
	    Scan s;
	    int res=0;

	    argl.setElem(0,cnt);
	    //System.out.println(">"+i+".."+ind);
	    Connection con = new Connection("");
	    //System.out.println("Calling ciota..");
	    s = con.callFunction(fname,argl);
	    while(!s.eos())
		{
		    t = s.getRow();
		    res = t.getIntElem(0);
		    //System.out.println("!"+t.getElem(0));
		    s.nextRow();
		}
	    //System.out.println("Disconnecting .."+ind);
	    if(res!=cnt) System.out.println("Wrong res:"+res+" for call:"
					     +cnt+
					     " in thread: "+this.ind); 
                                                 
	    con.disconnect();
	    //System.out.println("<Thread "+ind);
	}
	catch(AmosException e)
	    {System.out.println(e.getMessage()+ind);
	    e.printStackTrace();
	    }
	//System.out.println("<Tread "+ind);
    }
}

public class localThreads
{
    public static void main(String args[]) throws AmosException 
    {
	Connection.initializeAmos(args[0]);
        int threads = Integer.parseInt(args[1].trim());
        int loops = Integer.parseInt(args[2].trim());
        String fname = args[3];
        System.out.println("Testing "+threads+
                      " threads accessing local db  calling "+fname+"("
                      +loops+");");
        for(int i=0; i<threads; i++ )
	    {
		Thread t;
                //System.out.println("Initializing thread "+i);
		t = new MyLocalThread(i,loops,fname);
		t.start();
	    }
    }
}
