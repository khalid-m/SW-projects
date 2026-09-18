/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999 Daniel Elin, EDSLAB
 * $RCSfile: Oid.java,v $
 * $Revision: 1.24 $ $Date: 2009/01/06 14:54:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface between C type oidtype and Java class Oid
 * ===========================================================================
 * $Log: Oid.java,v $
 * Revision 1.24  2009/01/06 14:54:42  torer
 * Background computations possible in coroutine threads
 *
 * Revision 1.23  2007/07/27 12:28:25  torer
 * Loading of JavaAmos.dll only in class Connection
 *
 * Revision 1.22  2006/03/30 14:37:40  torer
 * Minor change
 *
 * Revision 1.21  2006/02/17 07:56:02  torer
 * Amos II typetag exported to Java allows for basic type access
 *
 ****************************************************************************/

package callin;

import java.util.*;

/**
 * Class corresponding to the AMOS-datatype oid.
 *
 * @author Daniel Elin
 * @version 1.8 (Last modified 990419)
 */
public class Oid {

    //
    // ===== Public interface ================================================
    //

    /**
     * Constructor used to clone Oid objects by its decendants
     */
    protected Oid()
    {
	super();
    }

    /**
     * Constructor. Used by the C-code.
     *
     * @param theOid Initializes this.oidtypeHandle.
     * @param theConnection Initializes this.theConnection.
     */
    private Oid(int oidtype, int typetag, Connection theConnection) {
	this.theConnection = theConnection;
	this.oidtypeHandle = oidtype;
	this.typeTag = typetag;
    }

    /**
     * Constructor.
     * Called from C when constructing Java proxy for Amos oidtype
     */

    private Oid(int oidtype) throws AmosException
    {
	this.oidtypeHandle = oidtype;
    }

    /**
     * Constructor.
     * Constructs an object of the specified type. The type-object can be
     * obtained with the method Connection.getType().
     * Uses the private method init().
     *
     * @param type The type of the object to be constructed.
     * @exception AmosException if the object couldn't be constructed.
     * @see callin.Connection#getType
     * @see callin.Oid#init
     */
    public Oid(Oid type) throws AmosException {
	this.init(type);
    }

    /**
     * Destructor.
     * Javas equivalent of a C++ destructor. Called when the object is up for
     * garbage-collection.
     * Uses the private method destroy().
     *
     * @see callin.Oid#destroy
     */
    protected void finalize() {
	this.destroy();
    }

    // ---------- Equalty ----------
    /**
     * Compares this OID-object to another. Overrides java.lang.Object.equals()
     * THIS IS NOT CORRECT! METHOD MUST BE NATIVE! /TR
     *
     * @param theObject The object that this object is to be compared to.
     * @return true if the objects are equal, false otherwise.
     * @see java.lang.Object#equals
     */
    public boolean equals(Object theObject) 
    {
	return ((theObject instanceof Oid) &&
		(this.oidtypeHandle == ((Oid)theObject).oidtypeHandle));
    }

    // ---------- Type ----------
    /**
     * Retrieves the type object for this object.
     *
     * @return This objects type object.
     * @exception AmosException if the type couldn't be found.
     */
    public native Oid getType() throws AmosException;

    // ---------- IDno ----------
    /**
     * Retrieves the OID-number of this object.
     *
     * @return This objects ID-number.
     * @exception AmosException if the OID-number couldn't be found.
     */
    public native int getID() throws AmosException;

    // ---------- Name ----------
    /**
     * Retrieves the typename of this object or the empty string if this object
     * has no name.
     * Uses a cached copy of name if available.
     *
     * @return The name of the type of this object.
     */
    public final String getTypename()
    {
	if (this.typename == null)
	    {
		try {
		    this.typename = 
			this.getConnection().callFunction("typename", this).
			getRow().getStringElem(0);
		}
		catch (AmosException e)
		    {
			this.typename = "ERROR";
		    }
	    }
	return (this.typename);
    }


/**
  * Copies properties of an Oid object
  */
  public Oid CopyProps(Oid o) throws AmosException
  {
     this.typename = o.typename;
     this.name = o.name;
     this.theConnection = o.theConnection;
     this.oidtypeHandle = o.oidtypeHandle;
     this.typeTag = o.typeTag;
     return o;
  }

    /**
     * Get Connection of Oid
     */
    public Connection getConnection() throws AmosException
    {
	if(this.theConnection!=null) return this.theConnection;
	else return Connection.localConnection();
    }

    // ---------- Name ----------
    /**
     * Retrieves the name of this object or the empty string if this object
     * has no name.
     * Uses a cached copy of name if available.
     *
     * @return The name of this object.
     */
    public final String getName()
    {
	if (this.name == null) {
	    try {
		// Named object
		this.name = this.getConnection().callFunction("name", this).
                    getRow().getStringElem(0);
	    }
	    catch (AmosException e) {
		// Unnamed object
		// don't call toString() here because it will deadlock!
		try
		    {
			this.name = "#[OID " + this.getID()+"]";
		    }
		catch(Exception e2)
		    {
			this.name = "**UnknownName**";
		    }
	    }
	}
	return (this.name);
    }

    // ---------- Clearing name cache ----------
    /**
     * Clears the (possibly) cached name of this Oid-object.
     */
    public void clearNameCache() {
	this.name = null;
    }

    // ---------- Clearing typename cache ----------
    /**
     * Clears the (possibly) cached typename of this Oid-object.
     */
    public void clearTypenameCache() {
	this.typename = null;
    }

    // ---------- Clearing all caches ----------
    /**
     * Clears the (possibly) cached typename and name of this Oid-object.
     */
    public void clearCache() {
	clearNameCache();
	clearTypenameCache();
    }

    // ---------- Printing ----------
    /**
     * Prints this object on the console.
     */
    public native void print();

    /**
     * Overrides Object.toString(). Uses the native method printToString().
     * Since the toString() can't throw exceptions but the printToString() 
     * method does throw AmosException, this method generates the string<br>
     * "<<< Exception generated during call to toString() >>>"<br>
     * and logs the exception to stderr in case of an exception.
     *
     * @return This objects String-representation (ex. #[OID 1 TYPE]).
     */
    public final String toString() {
	String msg;
	try {
	    msg = this.getName();
	    msg = (msg.equals("")) ? msg : " \"" + msg+ "\"";
	    msg = "#[OID " + this.getID() + msg + "]";
	}
	catch (AmosException e) {
	    System.err.println(e);
	    msg = ">>> Exception generated during call to toString() <<<";
	}
	return (msg);
    }

    public native String toAmosString();

    // ---------- Deleting ----------
    /**
     * Deletes this object from the database.
     *
     * @exception AmosException if the object couldn't be deleted.
     */
    public native void delete() throws AmosException;

    //
    // ===== Private interface ================================================
    //

    /**
     * Holds the handle-value of a variable declared with dcl_oid().
     * In C, the type oidtype is declared as:<br>
     * typedef unsigned int oidtype;<br>
     * It is safe to save this handle because once such a handle is declared
     * it doesn't change value. Of course, this implementation relies on the
     * fact that sizeof(unsigned int) = 4.
     */
    private volatile int oidtypeHandle;

    /**
     * Holds a handle-value to the connection variable declared in
     * callin.Connection.
     *
     * @see callin.Connection
     * @see callin.Connection#connectionPointer
     */
    private volatile Connection theConnection;

    /**
     * Holds the Amos II type tag as an integer
     * callin.Connection.
     *
     */
    public volatile int typeTag;

    /**
     * Cached value of this objects name.
     */
    private String name = null;

    /**
     * Cached value of a type proxy's name.
     */
    private String typename = null;

    /**
     * Used by the constructor because constructors can't be native.
     * Does a dcl_oid().
     *
     * @param type The type-object of the object to be constructed.
     * @exception AmosException if the object couldn't be constructed.
     */
    private native void init(Oid type) throws AmosException;

    /**
     * Used by the destructor because destructors cant be native.
     * Called when this object is about to be garbage-collected.
     * Does free_oid().
     *
     * @see callin.Oid#finalize
     */
    private native void destroy();



}
