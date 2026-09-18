package jspamos;

import callin.*;

/**
 * This class represents an Amos scan in Java.
 * Modified from automatically generated class by ACE.
 *
 * <DL><DT><B>CVS Info:</B><DD>
 * $RCSfile: TupleScan.java,v $
 * $State: Exp $ $Locker:  $
 * </DD></DT></DL>
 * @author  (c) 2003 Timour Katchaounov, UDBL
 * @version $Revision: 1.1 $, $Date: 2003/12/05 11:50:48 $
 */

public class TupleScan{

	private Scan theScan;
	private Connection con;

	public TupleScan(Scan s, Connection c){

		theScan = s;
		con = c;
	}

	public Tuple current() throws AmosException{

		if(!theScan.eos()){
			return theScan.getRow();
		}
		return null;
	}

	public void nextRow() throws AmosException{

		theScan.nextRow();
	}

	public boolean eos(){

		if(theScan.eos()){
			return true;
		}
		return false;
	}

}

