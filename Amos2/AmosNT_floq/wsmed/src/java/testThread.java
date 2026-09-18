import javax.xml.soap.*;
import java.util.*;
import callin.*;
import callout.*;


public class testThread implements Runnable 
{
   
    int finish=0;
    int sleeptime=0;
    boolean busy=false;
    javaTest jt=null;
    testThread()
    {}

    testThread(javaTest jt,int sleept,int val1) 
    {
	
	this.jt=jt;
	this.finish=val1;
	this.sleeptime=sleept;

    }
    
    void soapConn() throws SOAPException
    {
	try
	    {
			// All connections are created by using a connection factory
		SOAPConnectionFactory conFactory = SOAPConnectionFactory.newInstance();
	        
		System.out.println("SOAP connection succeed ");
		// Now we can create a SOAPConnection object using the connection factory
		SOAPConnection connection = conFactory.createConnection();
		}
	catch(Throwable ex)
	    {
	
	    }

    }
   
    public void run()
    {
		
	try
	    {
		//soapConn();
		Random generator = new Random();
		int randomIndex=generator.nextInt(20000);
		busy=true;
		Thread.sleep(1);
		busy=false;
		int[] arr = new int[finish];
		
		for (int i=1;i<=finish;i++)
		    	arr[i-1]=i+randomIndex;
						
		jt.setValue(arr);
		jt.waitSem.release(); // Let parent continue
		
	    }
	catch(Throwable ex)
	    {
	
	    }

    }
 }
