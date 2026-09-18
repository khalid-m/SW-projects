/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Johan Petrini, UDBL
 * $RCSfile: RDFScan.java,v $
 * $Revision: 1.1 $ $Date: 2008/02/08 12:49:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: RDFScan for RDFViewer cleint demonstation program
 * =========================================================================
 * $Log: RDFScan.java,v $
 * Revision 1.1  2008/02/08 12:49:07  udbl
 * *** empty log message ***
 *
 * Revision 1.2  2007/09/11 10:08:10  torer
 * Interface closer to specification
 *
 **************************************************************************/

package rdfview;
import java.util.Vector;

public class RDFScan {

    Vector res;
    int npos;
    int cpos;

    protected RDFScan(Vector v){
	
	    npos = v.size();
	    cpos = 0;
	    res = v;

    }
    

    protected void finalize() throws Throwable
    {
	res = null;

    } 
    
/**
 * Method that fetches the next row in a SwardScan.
 *
 * @return      the next row in the SwardScan as a Vector
 */

    public Vector next(){
	
	Vector row;
	
	row = (Vector)res.elementAt(cpos);
	cpos ++;
	return row; 
	
    }
   
/**
 * Method check for EOF in SwardScan.
 *
 * @return      true if EOF otherwise false
 */ 
    public Boolean eof(){
	
	if (cpos + 1 > npos){
	    
	    return true;
	    
	}else{
	    
	    return false;
	}

    }
}
