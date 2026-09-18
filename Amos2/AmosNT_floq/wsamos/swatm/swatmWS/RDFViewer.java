package swatmWS;

import java.util.Vector;

public class RDFViewer {
 
    String query;
    SwatmWSService serv;
    SwatmWS port;
    Vector arg;
    Vector res;
    		
    public RDFViewer(String urlstr) {
	try{
	serv = new SwatmWSServiceLocator();
	System.out.println("Connecting to RDFViewer service...");
	java.net.URL url = new java.net.URL(urlstr);
        System.out.println("Connected OK");
	port = serv.getSwatmWS(url);
        System.out.println("\nCalling Amos RDFViewer services ...");
	}
	catch (Exception e) {
	      System.out.println(e.getMessage());
	}

    }
    
/**
 * Query the UPV.
 *
 * @param  q    a query in RDQL
 * @return      a scan holding the result
 */	
public Vector query(String q){
    	try{
	    System.out.println("\nTesting to query RDF view of RDBB in terms of RDQL:" );
	    arg= new Vector();
	    arg.add(q);
	    res= port.callFunction("RDQL",arg);
	    
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}
	
	return res;
	
}

}

