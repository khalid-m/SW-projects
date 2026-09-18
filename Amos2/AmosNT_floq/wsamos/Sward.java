package wsamos;

import java.util.Vector;

public class Sward {
 
    String query;
    WebamosService serv;
    Webamos port;
    Vector arg;
    Vector res;
    		
    public Sward(String urlstr) {
	try{
	serv = new WebamosServiceLocator();
	System.out.println("Connecting to SWARD service...");
	java.net.URL url = new java.net.URL(urlstr);
        System.out.println("Connected OK");
	port = serv.getWebamos(url);
        System.out.println("\nCalling Amos SWARD services ...");
	}
	catch (Exception e) {
	      System.out.println(e.getMessage());
	}

    }
    
 /**
 * Connect to the UPV.
 *
 * @param  upv  a URI identifying the UPV
 * @param  u    the username of the UPV
 * @param  p    the password of the UPV
 */
    public void connect(String upv, String u, String p){
	
	try {
	    System.out.println("\nCalling upvconnect:" );
	    arg = new Vector();
	    arg.add(upv);
	    arg.add(u);
	    arg.add(p);
	    Vector res= port.callFunction("CHARSTRING.CHARSTRING.CHARSTRING.UPVCONNECT->BOOLEAN",arg);
	    Vector qres=(Vector) res.get(0);
	    Vector attr=(Vector) res.get(1);
	   	   
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}
    }


/**
 *  Disconnect the UPV.
 */
    public void disconnect(String upv){
	 try {
	    System.out.println("\nCalling upvdisconnect:" );
	    arg = new Vector();
	    arg.add(upv);
	    Vector res= port.callFunction("CHARSTRING.UPVDISCONNECT->BOOLEAN",arg);
	    Vector qres=(Vector) res.get(0);
	    Vector attr=(Vector) res.get(1);
	     
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}

    }

/**
 * Query the UPV.
 *
 * @param  q    a query in RDQL
 * @return      a scan holding the result
 */	
public Vector query(String q){
    	try{
	    System.out.println("\nTesting to query RDBB in terms of RDF by RDQL:" );
	    arg= new Vector();
	    arg.add(q);
	    res= port.callFunction("RDQL",arg);
	    
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}
	
	return res;
	
}

}

