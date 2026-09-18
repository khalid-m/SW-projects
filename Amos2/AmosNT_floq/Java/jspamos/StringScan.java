package jspamos;

import callin.*;

/**
 * This class represents an Amos scan of strings in Java.
 * Modified from automatically generated class by ACE.
 *
 * <DL><DT><B>CVS Info:</B><DD>
 * $RCSfile: StringScan.java,v $
 * $State: Exp $ $Locker:  $
 * </DD></DT></DL>
 * @author  (c) 2003 Timour Katchaounov, UDBL
 * @version $Revision: 1.1 $, $Date: 2003/12/05 11:50:48 $
 */
 
public class StringScan{

	private Scan theScan;
	private Connection con;

	public StringScan(Scan s, Connection c){

		theScan = s;
		con = c;
	}

	public String current() throws AmosException{

		if(!theScan.eos()){
			return theScan.getRow().getStringElem(0);
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

