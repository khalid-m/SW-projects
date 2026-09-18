import javax.xml.soap.*;
import callin.*;
import callout.*;

/* Uses the SAAJ library to consume a web service. */

public class soapTest
{
     /**
    * Invokes an operation using SAAJ
     */
     void  invokeConnection(CallContext cxt, Tuple tpl) throws SOAPException,AmosException 
    { 
	
	try
	    { 
		tpl.setElem(0,"Succeed");
		cxt.emit(tpl);
	     }
	catch(Throwable ex)
	    {
	
	    }
	
       
    }
      void  invokeConnection1(CallContext cxt, Tuple tpl) throws SOAPException,AmosException 
    { 
	
	try
	    { 
		System.out.println("Starting a SOAP connection ");
		
		// All connections are created by using a connection factory
		SOAPConnectionFactory conFactory = SOAPConnectionFactory.newInstance();
	        
		System.out.println("SOAP connection succeed ");
		// Now we can create a SOAPConnection object using the connection factory
		SOAPConnection connection = conFactory.createConnection();
	       
		tpl.setElem(0,"Succeed");
		cxt.emit(tpl);
	     }
	catch(Throwable ex)
	    {
	
	    }
	
	
	
       
    }
     void  invokeConnection2(CallContext cxt, Tuple tpl) throws SOAPException,AmosException 
    { 
	
	try
	    { 	
	       
		startThread();
		tpl.setElem(0,"Succeed");
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {
	
	    }
      
    }
    void startThread() throws AmosException 
    {
	try
	    { 
		Tuple btpl=new Tuple(0);
		Scan s=null;
		Connection theConnection = new Connection("");
		testThread tt= new testThread();
		Thread t=new Thread(tt);
		t.start();
		while(t.isAlive())
		    {
			//System.out.println("Calling busy");
			s = theConnection.callFunction("co_busy->charstring",btpl);
			//System.out.println("Back from busy");
		    }
	
	    }
	catch(Throwable ex)
	    {
	
	    }
    }
	  
} 
     
