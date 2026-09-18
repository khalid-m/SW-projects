/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Johan Petrini, UDBL
 * $RCSfile: RDFScan.java,v $
 * $Revision: 1.1 $ $Date: 2007/12/04 13:06:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: RDFScan for RDFViewer cleint demonstation program
 * =========================================================================
 * $Log: RDFScan.java,v $
 * Revision 1.1  2007/12/04 13:06:20  petrini
 * Added new interactive demo of SWARD JAVA API.
 *
 * Revision 1.2  2007/09/11 10:08:10  torer
 * Interface closer to specification
 *
 **************************************************************************/
package swardAPI;

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
 * Method that fetches the next row in a RDFScan.
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
