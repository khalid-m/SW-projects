/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, UDBL
 * $RCSfile: Scan.java,v $
 * $Revision: 1.13 $ $Date: 2012/11/01 21:34:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Java representation of Amos II objects
 * ===========================================================================
 * $Log: Scan.java,v $
 * Revision 1.13  2012/11/01 21:34:19  torer
 * New method Scan.close()
 *
 * Revision 1.12  2009/01/06 14:54:42  torer
 * Background computations possible in coroutine threads
 *
 ****************************************************************************/

package callin;

/**
  * Class corresponding to the AMOS-datatype scan.
  * A scan is a stream of tuples which can be iterated through.
  *
  * @author Daniel Elin
  * @version 1.5 (Last modified 990419)
  */
public class Scan {

  //
  // ===== Public interface ===================================================
  //

  /**
    *  Duummy construction for the time being.
    */
  public Scan(){}

  /**
    * Destructor.
    * Javas equivalent of a C++ destructor. Called when this object is up for
    * garbage-collection.
    * Uses the private method destroy().
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
    * @exception AmosException if the current tuple couldn't be fetched.
    * @see callin.Tuple
    */
  public native Tuple getRow() throws AmosException;

  /**
    * Gets the current tuple in this scan. The user has to supply the
    * ALLOCATED Tuple-object. This method gets the current tuple in this Scan
    * and stores it in the supplied Tuple-object. This is the prefered method
    * to use when iterating through large Scans.
    *
    * @param preAlloc The preallocated Tuple-object that will be updated and
    *                 returned.
    * @exception AmosException if the current tuple couldn't be fetched.
    * @see callin.Tuple
    */
  public native void getRow(Tuple preAlloc) throws AmosException;

  /**
    * Converts this Scan into a java.util.Vector object.
    * <br><br>
    * WARNING! THIS METHOD IS GROSSLY INEFFICIENT IN BOTH TIME AND SPACE IF
    * THE SCAN IS LONG!
    *
    * @return This scan converted to a Vector-object.
    * @exception AmosException if the scan couldn't be converted.
    * @see java.util.Vector
    */
  public java.util.Vector toVector() throws AmosException {
    java.util.Vector theVector = new java.util.Vector(0);

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
    * @exception AmosException if there are no more tuples in the scan.
    * @see callin.Tuple
    */
  public native void nextRow() throws AmosException;

  /**
    * Tests for end of scan.
    *
    * @return true if there are no more tuples in this scan, false otherwise.
    * @see callin.Tuple
    */
    public native boolean eos();

    // ---------- Close secondary scan ----------
    /**
     * Closes a secondary scan opened with Connection.openScan().
     *
     * @exception AmosException if the scan couldn't be closed.
     * @see callin.Connection#openScan
     */
    public native void closeScan() throws AmosException;
    public void close() throws AmosException
    {
	this.closeScan();
    }

  //
  // ===== Private interface ==================================================
  //

  /**
    * Holds the pointer-value of a variable declared with dcl_scan().
    * In C, the type a_scan is declared as:<br>
    * typedef struct ... *a_scan;<br>
    * It is safe to save this pointer because once such a pointer is declared
    * it doesn't change value. Of course, this implementation relies on the
    * fact that sizeof(struct ... *) = 4.
    */
  private volatile int scanPointer;

  /**
    * Holds a pointer-value to the Connection this Scan belongs to.
    *
    * @see callin.Connection#connectionPointer
    */
  private Connection theConnection;

  /**
    * Constructor. Used by the C-code.
    *
    * @param theScan Initializes this.scanPointer.
    * @param theConnection Initializes this.theConnection.
    * @see callin.Scan#scanPointer
    * @see callin.Scan#theConnection
    */
  private Scan(int theScan, Connection theConnection) {
    this.theConnection = theConnection;
    this.scanPointer = theScan;
  }

  /**
    * Used by the destructor because destructors cant be native.
    * Called when this object is about to be garbage-collected.
    * Does free_scan().
    *
    * @see callin.Scan#finalize
    */
  private native void destroy();

}
