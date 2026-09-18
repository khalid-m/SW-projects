/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, UDBL
 * $RCSfile: Scan.java,v $
 * $Revision: 1.1 $ $Date: 2013/08/12 11:36:57 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Java representation of Amos II objects
 * ===========================================================================
 * $Log: Scan.java,v $
 * Revision 1.1  2013/08/12 11:36:57  shsh6828
 * *** empty log message ***
 *
 * Revision 1.12  2009/01/06 14:54:42  torer
 * Background computations possible in coroutine threads
 *
 ****************************************************************************/

package udbl.amos.purejavaclient;


import java.util.Vector;

/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, UDBL
 * $RCSfile: Scan.java,v $
 * $Revision: 1.1 $ $Date: 2013/08/12 11:36:57 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Java representation of Amos II objects
 * ===========================================================================
 * $Log: Scan.java,v $
 * Revision 1.1  2013/08/12 11:36:57  shsh6828
 * *** empty log message ***
 *
 * Revision 1.13  2012/11/01 21:34:19  torer
 * New method Scan.close()
 *
 * Revision 1.12  2009/01/06 14:54:42  torer
 * Background computations possible in coroutine threads
 *
 ****************************************************************************/

/**
 * Class corresponding to the AMOS-datatype scan. A scan is a stream of tuples
 * which can be iterated through.
 * 
 * @author Daniel Elin
 * @version 1.5 (Last modified 990419)
 */
public class Scan {

	//
	// ===== Public interface
	// ===================================================
	//

	/**
	 * Duummy construction for the time being.
	 */
	/**
	 * Destructor. Javas equivalent of a C++ destructor. Called when this object
	 * is up for garbage-collection. Uses the private method destroy().
	 * 
	 * @see callin.Scan#destroy
	 */
	protected void finalize() {
		this.destroy();
	}

	// ---------- Tuple handling ----------
	/**
	 * Gets the current tuple in this scan.
	 * 
	 * @return The current tuple.
	 * @exception AmosException
	 *                if the current tuple couldn't be fetched.
	 * @see callin.Tuple
	 */
	public Tuple getRow() throws AmosException {
		String res="",rec="";
		this.theConnection.scToSCSQ.WriteToSocket("(scan-getcurrent s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");
		this.theConnection.scToSCSQ.SendToSocket();
    	rec = this.theConnection.scToSCSQ.ReadFromSocket();
    	if(rec.charAt(0)!='(')
    		rec = "("+rec+")";
    	LispObject lsp = this.theConnection.rp.read(rec);
    	if(lsp!=null)
    		res = this.theConnection.rp.print(lsp);
    	else
    		res = "";
    	//System.out.println(rec);
    	TupleMaker tpm = new TupleMaker(res);
    	tpm.tp.theConnection=this.theConnection;
		return tpm.tp;
	}

	/**
	 * Gets the current tuple in this scan. The user has to supply the ALLOCATED
	 * Tuple-object. This method gets the current tuple in this Scan and stores
	 * it in the supplied Tuple-object. This is the prefered method to use when
	 * iterating through large Scans.
	 * 
	 * @param preAlloc
	 *            The preallocated Tuple-object that will be updated and
	 *            returned.
	 * @exception AmosException
	 *                if the current tuple couldn't be fetched.
	 * @see callin.Tuple
	 */
	public void getRow(Tuple preAlloc) throws AmosException {
		
	}

	/**
	 * Converts this Scan into a java.util.Vector object. <br>
	 * <br>
	 * WARNING! THIS METHOD IS GROSSLY INEFFICIENT IN BOTH TIME AND SPACE IF THE
	 * SCAN IS LONG!
	 * 
	 * @return This scan converted to a Vector-object.
	 * @exception AmosException
	 *                if the scan couldn't be converted.
	 * @see java.util.Vector
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public Vector toVector() throws AmosException {
		Vector theVector = new Vector(0);

		while (!this.eos()) {
			theVector.addElement(this.getRow().toVector());
			this.nextRow();
		}
		return (theVector);
	}

	/**
	 * Advances this scan forward, i.e. sets the current tuple to the next tuple
	 * in this scan.
	 * 
	 * @exception AmosException
	 *                if there are no more tuples in the scan.
	 * @see callin.Tuple
	 */
	public void nextRow() throws AmosException{
		
		String res="";
		this.theConnection.scToSCSQ.WriteToSocket("(scan-nextrow s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");
		this.theConnection.scToSCSQ.SendToSocket();
    	res=this.theConnection.scToSCSQ.ReadFromSocket();
	}

	/**
	 * Tests for end of scan.
	 * 
	 * @return true if there are no more tuples in this scan, false otherwise.
	 * @throws AmosException 
	 * @see callin.Tuple
	 */
	public boolean eos() throws AmosException{
		String con1="",con2="";
		if(this.theConnection==null)
			return true;
		this.theConnection.scToSCSQ.WriteToSocket("(scan-getcurrent s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");
    	this.theConnection.scToSCSQ.SendToSocket();
    	con1 = this.theConnection.scToSCSQ.ReadFromSocket();
    	if(con1.equals("NIL") || con1.equals("RESOLVENAME"))
    		return true;
		return false;
	}
	// ---------- Close secondary scan ----------
	/**
	 * Closes a secondary scan opened with Connection.openScan().
	 * 
	 * @exception AmosException
	 *                if the scan couldn't be closed.
	 * @see callin.Connection#openScan
	 */
	public void closeScan() throws AmosException{
		String res="";
		this.theConnection.scToSCSQ.WriteToSocket("(scan-close s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");

    	this.theConnection.scToSCSQ.SendToSocket();
    	res=this.theConnection.scToSCSQ.ReadFromSocket();

    	this.theConnection.scToSCSQ.WriteToSocket("(buffer-clear b");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");
    	this.theConnection.scToSCSQ.SendToSocket();
    	res=this.theConnection.scToSCSQ.ReadFromSocket();
		
	}

	public void close() throws AmosException {
		this.closeScan();
	}

	//
	// ===== Private interface
	// ==================================================
	//

	/**
	 * Holds the pointer-value of a variable declared with dcl_scan(). In C, the
	 * type a_scan is declared as:<br>
	 * typedef struct ... *a_scan;<br>
	 * It is safe to save this pointer because once such a pointer is declared
	 * it doesn't change value. Of course, this implementation relies on the
	 * fact that sizeof(struct ... *) = 4.
	 */
	private volatile int scanPointer;
	private boolean scanTerminated;
	private boolean nextNill;
	/**
	 * Holds a pointer-value to the Connection this Scan belongs to.
	 * 
	 * @see callin.Connection#connectionPointer
	 */
	public Connection theConnection;

	/**
	 * Constructor. Used by the C-code.
	 * 
	 * @param theScan
	 *            Initializes this.scanPointer.
	 * @param theConnection
	 *            Initializes this.theConnection.
	 * @see callin.Scan#scanPointer
	 * @see callin.Scan#theConnection
	 */
	public Scan(int theScan, Connection theConnection) throws AmosException {
		String res="";
		this.theConnection = theConnection;
		this.scanPointer = theScan;
		this.theConnection.scToSCSQ.WriteToSocket("(setq s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(" (gethash ");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(" _scan-list_))");

		this.theConnection.scToSCSQ.SendToSocket();
		res=this.theConnection.scToSCSQ.ReadFromSocket();

		this.theConnection.scToSCSQ.WriteToSocket("(scan-fillbuffer s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(")");
		this.theConnection.scToSCSQ.SendToSocket();
		res=this.theConnection.scToSCSQ.ReadFromSocket();

		this.theConnection.scToSCSQ.WriteToSocket("(setq b");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(" (scan-buffer s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket("))");
		this.theConnection.scToSCSQ.SendToSocket();
		res=this.theConnection.scToSCSQ.ReadFromSocket();

		this.theConnection.scToSCSQ.WriteToSocket("(scan-setcurrent s");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket(" (buffer-peek b");
		this.theConnection.scToSCSQ.WriteToSocket(Integer.toString(this.scanPointer));
		this.theConnection.scToSCSQ.WriteToSocket("))");
		this.theConnection.scToSCSQ.SendToSocket();
		res=this.theConnection.scToSCSQ.ReadFromSocket();
		this.nextRow();
	}	
	public Scan(){
		this.scanPointer=1;
		this.scanTerminated=true;
		this.theConnection=null;
		this.nextNill=false;
	}
	/**
	 * Used by the destructor because destructors cant be native. Called when
	 * this object is about to be garbage-collected. Does free_scan().
	 * 
	 * @see callin.Scan#finalize
	 */
	private void destroy(){
		
	}

}
