
import callin.*;
import callout.*;
import java.util.concurrent.Semaphore;


public class javaTest
{
     
    int[] value=null; 
    public Semaphore waitSem = new Semaphore(0);
   
     /**
    * Invokes a java function
     */
    public void startThread(CallContext cxt, Tuple tpl) throws AmosException 
    {
	Tuple btpl=new Tuple(0);
	Scan s=null;
	try
	    { 
		javaTest jt= new javaTest();
		testThread t1= new testThread(jt,tpl.getIntElem(0),tpl.getIntElem(1));
	
		Thread tt1=new Thread(t1);

		Oid bg = cxt.getBG();
		cxt.enterBG(bg);
		tt1.start(); // Start child thread
		jt.waitSem.acquire(); // Wait for child to finish
		//while (jt.value==null){}
		cxt.leaveBG(bg);
	
		for(int i=0;i<jt.value.length;i++)
		    {	
			tpl.setElem(2,jt.value[i]);
			cxt.emit(tpl);
		    }
	
	    }
	catch(Throwable ex)
	    {
	
	    }
    }

    void setValue (int[] i)
    {
	value=i;
    }
     int[] getValue ()
    {
	int[] temp=value;
	value=null;
	return temp;
    }
   
	  
} 
     
