/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Johan Petrini, UDBL
 * $RCSfile: RDFViewer.java,v $
 * $Revision: 1.3 $ $Date: 2008/02/22 13:20:55 $
 * $State: Exp $ $Locker:  $
 *
 * Description: RDFViewer web service client interface
 * =========================================================================
 * $Log: RDFViewer.java,v $
 * Revision 1.3  2008/02/22 13:20:55  petrini
 * Removed bugs from code.
 * Added very simple translator from Perl to AmosQL regex used when parsing RDQL and SPARQL queries.
 * Added RDFS classes as rdfs:range for foreign keys.
 * Added parameterized fns for serializing composite key values.
 * Deleting unused files.
 *
 * Revision 1.2  2007/12/04 15:18:23  petrini
 * Added updated readme file.
 *
 * Revision 1.1  2007/12/04 13:06:20  petrini
 * Added new interactive demo of SWARD JAVA API.
 *
 * Revision 1.3  2007/09/13 14:00:53  udbl
 * Demo Client files
 *
 * Revision 1.2  2007/09/11 10:22:10  torer
 * Interface closer to specification
 *
 * Revision 1.1  2007/09/11 09:54:35  torer
 * Jave code
 *
 **************************************************************************/
package swardAPI;

import java.util.Vector;
import callin.*;

public class RDFViewer {
	
    Connection theConnection;	// To hold the connection to AMOS
    Tuple row;	              // To hold results from AMOS function calls
    String query;
    static Boolean initialized = false;
		
    /**
     * Constructor of RDFViewer.
     *
     * @param  name    name of SWARD database to connect to
     */
    public RDFViewer(String swdb){
    
	Scan res;
	Tuple argl;    
        
        try{
	    if (!initialized){
		System.out.println("\nInitializing ....");
		Connection.initializeAmos(swdb);
		initialized = true;
	    }
	    theConnection = new Connection("");
	    argl = new Tuple(0); 
	    res = theConnection.callFunction("connectAllUPV->Boolean",argl);
	}catch(Exception e){System.out.println(e.getMessage());System.exit(0);}
    }

    /**
     * Query the SWARD database.
     *
     * @param  q    a query in RDQL
     * @return      a scan holding the result
     */	
    public RDFScan RDQL(String q) throws AmosException{
	
        Tuple tmp;
	Tuple r;
	Tuple argl;
	Scan s;
	RDFScan rs;
        int ra;
        Tuple vvp;
        Vector vvvp;
	Vector vs = new Vector();
	

	argl = new Tuple(1); 
	argl.setElem(0, q);
	s = theConnection.callFunction("Charstring.RDQLBinds->Vector",argl);

	while (!s.eos()){

	    Vector vr = new Vector();
	    int rowArity=0;
	    int j=0;
   
	    tmp = s.getRow();
	    r = tmp.getSeqElem(0);
	    ra = r.getArity();	

	    while(j < ra){
                vvvp = new Vector();
		vvp = r.getSeqElem(j);
		vvvp.add(vvp.getStringElem(0));
                if(vvp.isString(1)) vvvp.add(vvp.getStringElem(1));
                else if(vvp.isInteger(1)) vvvp.add(vvp.getIntElem(1));
                else if(vvp.isDouble(1)) vvvp.add(vvp.getDoubleElem(1));
		vr.add(vvvp);
		j++;
	    }
		
	    vs.add(vr);		
	    s.nextRow(); 
	}
  
	rs = new RDFScan(vs);
	return rs;
    }
}

