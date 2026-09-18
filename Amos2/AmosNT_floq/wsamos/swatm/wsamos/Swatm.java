package wsamos;

import java.util.Vector;

public class Swatm {
 
    String query;
    WebamosService serv;
    Webamos port;
    Vector arg;
    Vector res;
    		
    public Swatm(String urlstr) {
	try{
	serv = new WebamosServiceLocator();
	System.out.println("Connecting to RDF View service...");
	java.net.URL url = new java.net.URL(urlstr);
        System.out.println("Connected OK");
	port = serv.getWebamos(url);
        System.out.println("\nCalling Amos SWATM services ...");
	}
	catch (Exception e) {
	      System.out.println(e.getMessage());
	}

    }
    
 /**
 * Connect to the UPV.
 *
 */
    public void connect(String xtmfileuri){
	
	try {
	    System.out.println("\nCalling DefineUPV:" );
	    arg = new Vector();
	    arg.add(xtmfileuri);
	    Vector res= port.callFunction("DEFINEUPV",arg);
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
	    System.out.println("\nTesting to query a Topic Map, stored in a xtm file in terms of RDF by RDQL:" );
	    arg= new Vector();
	    arg.add(q);
	    res= port.callFunction("RDQL",arg);
	    
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}
	
	return res;
	
}

}

