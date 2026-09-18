import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;
import java.util.*;


class PSELOInterface {

    protected static final String anonDmp = "../bin/amos2.dmp";	 
    protected static boolean init = false;
    protected String argv[] = {anonDmp};
    
    //Multi-threaded execution of JAVA-C interface.
    public synchronized void initAmos(int i){
	if(init == false){
	    init = true;
	    System.out.println("Trying to initialize Amos");								
	    try{
		Connection.initializeAmos(argv);
		System.out.println("Initialized Amos in thread:" + i);
	    }catch(AmosException e){
		System.out.println("Exception in SyncInterface.initAmos() -> Restarting system.");
		System.out.println(e.getMessage());
		e.printStackTrace();
		//System.exit(1);
	    }		 
	}
    }		  		  
    
    //Multi-threaded execution of JAVA-C interface.
    public synchronized void execQuery(int i){		  
	Connection con=null;
	try {
	    
	    System.out.println("Trying to create connection to PSELO in thread:" +i);								
	    con = new Connection("FOO");
	    System.out.println("Created connection to PSELO in thread:" +i);
	    
	    System.out.println("Trying to execute query against PSELO in thread:" + i);

	    Tuple argl=new Tuple(1);
	    con.callFunction("OBJECT.ID->OBJECT",argl);
	    System.out.println("Executed query against PSELO in thread" + i);
	    
	    System.out.println("Trying to disconnect connection to PSELO");
	    con.disconnect();
	    System.out.println("Disconnected connection to PSELO in thread" + i);	    	    
	
	}catch(AmosException e){
	    System.out.println("Exception in SyncInterface.execQuery() -> Restarting system.");
	    System.out.println(e.getMessage());
	    e.printStackTrace();
	    //System.exit(1);
	}
    } 
    
}

class MyThread3 extends Thread
{
    public static PSELOInterface pInt = new PSELOInterface();
    int ind, cnt;
    MyThread3(int m, int cnt)
    {
        this.ind = m;
	this.cnt = cnt;
    }
    public void run()
    {   
        int i;
	int j;

	for(i=0;i<cnt;i++)
	    {				
		Random rand = new Random();
		j = rand.nextInt() % 500;
		System.out.println(j);
		if(j >= 0){
		try{sleep(j);}
		catch(InterruptedException e){}}
		pInt.initAmos(ind);
		pInt.execQuery(ind);
		
	    }
	//}
	//catch(AmosException e)
	//{System.out.println(e.getMessage()+ind);
	//e.printStackTrace();
    }
    //System.out.println("<Tread "+ind);
}


public class trazan3
{
    public static void main(String args[]) throws AmosException 
    {
	//Connection.initializeAmos("../bin/amos2.dmp");
        int threads = Integer.parseInt(args[0].trim());
        int loops = Integer.parseInt(args[1].trim());
        for(int i=0; i<threads; i++ )
	    {
		Thread t;
                System.out.println("Initializing thread "+i);
		t = new MyThread3(i,loops);
		t.start();
	    }
    }
}
